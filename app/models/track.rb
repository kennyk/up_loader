require 'rubygems'
require 'uuidtools'
require 'taglib'

class Track < ActiveRecord::Base
  
  @@publicDir = "public"
  @@tracksDir = "files"
  
  #Save the metadata and write the file,
  #converting to .ogg if possible.  The
  #non-db portion shoud be refactored to be
  #run on a separate thread - pehaps use 
  # delayed_job? http://github.com/tobi/delayed_job
  def save(upload)
    uploadFile = upload['datafile']
    originalName = uploadFile.original_filename
    self.fileType = File.extname(originalName)

    create_or_update()

    # write the file
    File.open(self.filePath, "wb") { |f| f.write(uploadFile.read) }
    
    # write ID3 metadata to database, to avoid the expense of fetching
    # from the file every time - quite costly as more files are displayed at a time
    begin
      musicFile = TagLib::File.new(self.filePath())
      self.id3Title = musicFile.title
      self.id3Artist = musicFile.artist
      self.id3Length = musicFile.length
     rescue TagLib::BadFile => exc
        logger.error("Failed to id track: \n #{exc}")
    end

    if(self.fileType == '.mp3')
      convertToOGG();
    end
    create_or_update()

  end
  
  #Modify the ID3 tags in the file
  def update_ID3(attributes)
     begin
      musicFile = TagLib::File.new(self.filePath())
      musicFile.title = attributes[:id3Title]
      musicFile.artist = attributes[:id3Artist]
      musicFile.save()
     rescue TagLib::BadFile => exc
      logger.error("Failed to id track: \n #{exc}")
    end  
  end
  
  
  def rename(newName)
    self.name = newName
    create_or_update()
  end
  
  def destroy()
    # Only attempt to delete file if it exists;
    # otherwise only delete the metadata from db
    File.delete(self.filePath) if File.exist?(self.filePath)
    super
  end
  
  #convert seconds into hh:mm:ss
  def displayTrackLength()
    if(self.id3Length)
      return [self.id3Length/3600, self.id3Length/60 % 60, self.id3Length % 60].map{|t| t.to_s.rjust(2, '0')}.join(':')
     end
  end
  
  #get file path for local operations
  def filePath()
    return File.join(@@publicDir, @@tracksDir, "#{self.fileName}#{self.fileType}").to_s
  end
  
  #get file path for web retrieval
  def relativeWebPath()
    return File.join('/', @@tracksDir, "#{self.fileName}#{self.fileType}")
  end
  
  #convert to .ogg by piping wav output from mpg321 to oggenc
  #this takes about 15-20 seconds for a 5-min track, definitely
  #should be done in the background.  
  def convertToOGG()
    call = "mpg321 #{File.join(RAILS_ROOT, self.filePath)} -w - | oggenc -o #{ File.join(RAILS_ROOT, @@publicDir, @@tracksDir, self.fileName)}.ogg -"
    system(call)
    File.delete(self.filePath) if File.exist?(self.filePath)
    self.fileType = ".ogg"
    
    #ID3 tags get lost in the conversion process - put them back into file
    begin
      musicFile = TagLib::File.new(self.filePath())
      musicFile.title = self.id3Title
      musicFile.artist = self.id3Artist
      musicFile.save()
     rescue TagLib::BadFile => exc
      logger.error("Failed to id track: \n #{exc}")
    end
    
    
  end
  
  
end
