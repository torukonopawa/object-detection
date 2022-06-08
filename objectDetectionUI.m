function varargout = objectDetectionUI(varargin)
% OBJECTDETECTIONUI MATLAB code for objectDetectionUI.fig
%      OBJECTDETECTIONUI, by itself, creates a new OBJECTDETECTIONUI or raises the existing
%      singleton*.
%
%      H = OBJECTDETECTIONUI returns the handle to a new OBJECTDETECTIONUI or the handle to
%      the existing singleton*.
%
%      OBJECTDETECTIONUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OBJECTDETECTIONUI.M with the given input arguments.
%
%      OBJECTDETECTIONUI('Property','Value',...) creates a new OBJECTDETECTIONUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before objectDetectionUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to objectDetectionUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help objectDetectionUI

% Last Modified by GUIDE v2.5 25-Apr-2022 19:11:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @objectDetectionUI_OpeningFcn, ...
                   'gui_OutputFcn',  @objectDetectionUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before objectDetectionUI is made visible.
function objectDetectionUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to objectDetectionUI (see VARARGIN)

%--> Check if cam available
if(isempty(webcamlist))
    display('--> No camera found on system');
end
%--> Assign cam
handles.cam = webcam(1);
%--> Check start stop condition (1 or 0)
handles.isWorking = 1;
%--> Fudge factor for filtering (higher than 0)
handles.fudgeFactor = 1;
%--> At start show BW image
handles.imageFormat = 3;
%--> Set initial/final coords
handles.initialCoords = 1;
handles.finalCoords = 1;

% Choose default command line output for objectDetectionUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes objectDetectionUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = objectDetectionUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on selection change in imageSelect.
function imageSelect_Callback(hObject, eventdata, handles)
% hObject    handle to imageSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns imageSelect contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageSelect

% --- Executes during object creation, after setting all properties.
function imageSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function cameraOutput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cameraOutput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% Hint: place code in OpeningFcn to populate cameraOutput

% --- Executes on button press in startStopButton.
function startStopButton_Callback(hObject, eventdata, handles)
% hObject    handle to startStopButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isFirst = 1;
%--> SEND SNAPSHOT TO FUNCTION
while 1
    fudgeVal = get(handles.fudgeSlider, 'Value');
    set(handles.fudgeString, 'String', fudgeVal);
    
    imageFormat = get(handles.imageSelect, 'Value');
    
%     [~, handles.currentFrame] = findObjectFromImage(snapshot(handles.cam), fudgeVal);
%     imshow(handles.currentFrame);
    
    guidata(hObject, handles);

    %with filter
    [centerCoords, ~] = findObjectFromImage(snapshot(handles.cam), fudgeVal, imageFormat);
    %with subtraction
%     first = snapshot(handles.cam);
%     for i = 1:500
%         i = i + 1;
%     end
%     [centerCoords, ~] = findFrom2Images(first, snapshot(handles.cam));
    
    if(~isempty(centerCoords))
        set(handles.xCoord, 'String', centerCoords(1));
        set(handles.yCoord, 'String', centerCoords(2));
        
        %CALCULATE SPEED
        if(isFirst)
            tic;
            % setInitialCoords
            handles.initialCoords = centerCoords;
            isFirst = 0;
        else
            timePassed = toc;
            % setFinalCoords
            handles.finalCoords = centerCoords;
            isFirst = 1;
            
            % calculate SPEED
            xChange = abs(handles.initialCoords(1) - handles.finalCoords(1));
            yChange = abs(handles.initialCoords(2) - handles.finalCoords(2));
            
            distanceTaken = hypot(xChange, yChange);
            
            speed = distanceTaken / timePassed;
            % pixel/sec * meter/pixel meter:objectSize pixel:inCamera
                %display(hypot(abs(handles.initialCoords(1) - handles.finalCoords(1)),abs(handles.initialCoords(2) - handles.finalCoords(2)))/timePassed);
            display(speed);
        end
    end
    
    if(get(hObject, 'Value'))
        %imshow('unknown.png');
        break;
    end
end

% --- Executes on slider movement.
function fudgeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to fudgeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
% Update handles structure
%guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fudgeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fudgeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
