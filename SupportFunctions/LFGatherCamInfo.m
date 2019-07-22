% LFGatherCamInfo - collect metadata from a folder of processed white images or calibrations
%
% Usage: 
% 
%   CamInfo = LFGatherCamInfo( FilePath, FilenamePattern )
% 
% 
% This function is designed to work with one of two sources of information: a folder of Lytro white
% images, as extracted from the calibration data using an LFP tool; or a folder of calibrations, as
% generated by LFUtilCalLensletCam. 
% 
% Inputs: 
% 
%   FilePath is a path to the folder containing either the white images or the calibration files.
% 
%   FilenamePattern is a pattern, with wildcards, identifying the metadata files to process. Typical
%   values are 'CalInfo*.json' for calibration info, and '*T1CALIB__MOD_*.TXT' for white images.
%   
% Outputs:
% 
%   CamInfo is a struct array containing zoom, focus and filename info for each file. Exposure info
%   is also included for white images.
% 
% See LFUtilProcessCalibrations and LFUtilProcessWhiteImages for example usage.
% 
% See also:  LFUtilProcessWhiteImages, LFUtilProcessCalibrations

% Part of LF Toolbox v0.4 released 12-Feb-2015
% Copyright (c) 2013-2015 Donald G. Dansereau

function CamInfo = LFGatherCamInfo( FilePath, FilenamePattern )

%---Locate all input files---
[FileNames, BasePath] = LFFindFilesRecursive( FilePath, FilenamePattern );
if( isempty(FileNames) )
    error('No files found');
end
fprintf('Found :\n');
disp(FileNames)

%---Process each---
fprintf('Filename, Camera Model / Serial, ZoomStep, FocusStep\n');
for( iFile = 1:length(FileNames) )
    CurFname = FileNames{iFile};
    CurFileInfo = LFReadMetadata( fullfile(BasePath, CurFname) );
    
    CurCamInfo = [];
    if( isfield( CurFileInfo, 'CamInfo' ) )
        
        %---Calibration file---
        CurCamInfo = CurFileInfo.CamInfo;
        
    elseif( isfield( CurFileInfo, 'master' ) )
        
        %---Lytro TXT metadata file associated with white image---
        CurCamInfo.ZoomStep = CurFileInfo.master.picture.frameArray.frame.metadata.devices.lens.zoomStep;
        CurCamInfo.FocusStep = CurFileInfo.master.picture.frameArray.frame.metadata.devices.lens.focusStep;
        CurCamInfo.ExposureDuration = CurFileInfo.master.picture.frameArray.frame.metadata.devices.shutter.frameExposureDuration;
        CurCamInfo.CamSerial = CurFileInfo.master.picture.frameArray.frame.privateMetadata.camera.serialNumber;
        CurCamInfo.CamModel = CurFileInfo.master.picture.frameArray.frame.metadata.camera.model;
        
    else
        
        error('Unrecognized file format reading metadata\n');
        
    end

    fprintf('    %s :\t%s / %s, %d, %d\n', CurFname, CurCamInfo.CamModel, CurCamInfo.CamSerial, CurCamInfo.ZoomStep, CurCamInfo.FocusStep);
    
    CurCamInfo.Fname = CurFname;
    CamInfo(iFile) = CurCamInfo;
end
