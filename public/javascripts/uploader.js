/**
 * @author Kenny Kremerman
 */
 
 function startUpload() 
 {
	$('track_submit').hide();
	$('progressFrame').show();
 	$('progress').show();
    var uuid = $('X-Progress-ID').value;	
	var progress_bar = new Control.ProgressBar(
		'progress_bar',
		{ interval: 1, 
                  url: '/progress?X-Progress-ID=' + uuid }
	);
	
	$('track_submit').observe('click', progress_bar.start.bind(progress_bar));
	$('track_submit').observe('click', progress_bar.poll('/progress?X-Progress-ID=' + uuid, 1, {method:'GET'}));
	$('track_submit').observe('click', $('fileUploadPrompt').hide());
	
	//Start polling for completion of upload and encode
 	//to ensure the correct order - the save is transactional
	//so we must be sure it's finished before trying to modify
	//any data
	new PeriodicalExecuter(function(pe) {
			if (!($('progressFrame').contentDocument.URL.include('about:blank')))
			{
	        	renameTrack();
				pe.stop();
			}
		}, 1);
	}

function renameTrack()
{
	$('namePrompt').hide();
	new Ajax.Request('/tracks/rename', {
		method: 'get',
		parameters: {newName: $('track_name').value,
					 fileName: $('X-Progress-ID').value}, //we don't yet have the track's ID, but we have its uuid, guaranteed unique (see controller)
		onSuccess: function(transport) {
			$('heading').update(transport.responseText);
		}
	});
	
	return false;
}

function onLoad()
{
	$('upload_datafile').observe('change', $('track_name').update(
		$('upload_datafile').value.split('/').last().split('\\').last()) );
}

function updateName()
{
	var fileNameArray = $('upload_datafile').value.split('/').last().split('\\').last().split('.');//get file name, split that by '.'
	$('track_name').value = fileNameArray.splice(0, fileNameArray.length-1).join();
	updateNameDisplay();
}

function updateNameDisplay()
{
	$('heading').update($('track_name').value);
}
