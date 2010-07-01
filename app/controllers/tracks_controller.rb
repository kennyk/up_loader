require 'rubygems'
require 'uuidtools'

class TracksController < ApplicationController
  # GET /tracks
  # GET /tracks.xml
  def index
    @tracks = Track.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /tracks/1
  # GET /tracks/1.xml
  def rename
    @track = Track.find_by_sql("select * from tracks where fileName='#{params[:fileName]}'")[0]
    @newName = params[:newName]
    @track.rename(@newName)

    respond_to do |format|
      format.html { render :partial => 'tracks/renamed' }
    end
  end

  # GET /tracks/new
  # GET /tracks/new.xml
  def new
    @track = Track.new
    
    #guarantee a unique uuid by checking against db
    @uuid = UUIDTools::UUID.timestamp_create().to_s
    while(Track.find_by_sql("select * from tracks where fileName='#{@uuid}'").length != 0)
      @uuid = UUIDTools::UUID.timestamp_create().to_s
    end

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /tracks/1/edit
  def edit
    @track = Track.find(params[:id])
  end

  # POST /tracks
  # POST /tracks.xml
  def create
    @track = Track.new(params[:track])

    respond_to do |format|
      if @track.save(params[:upload])     
        format.html { render :partial => 'tracks/uploaded' }
      else
        format.html { render :partial => 'tracks/failed' }
      end
    end
  end

  # PUT /tracks/1
  # PUT /tracks/1.xml
  def update
    @track = Track.find(params[:id])

    respond_to do |format|
      if @track.update_attributes!(params[:track]) && @track.update_ID3(params[:track])
        @tracks = Track.all
        format.html { render :action => "index" }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /tracks/1
  # DELETE /tracks/1.xml
  def destroy
    @track = Track.find(params[:id])
    @track.destroy

    respond_to do |format|
      format.html { redirect_to(tracks_url) }
    end
  end
end
