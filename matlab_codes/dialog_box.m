function varargout = dialog_box(varargin)
% DIALOG_BOX MATLAB code for dialog_box.fig
%      DIALOG_BOX, by itself, creates a new DIALOG_BOX or raises the existing
%      singleton*.
%
%      H = DIALOG_BOX returns the handle to a new DIALOG_BOX or the handle to
%      the existing singleton*.
%
%      DIALOG_BOX('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DIALOG_BOX.M with the given input arguments.
%
%      DIALOG_BOX('Property','Value',...) creates a new DIALOG_BOX or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dialog_box_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dialog_box_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dialog_box

% Last Modified by GUIDE v2.5 25-May-2020 11:32:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dialog_box_OpeningFcn, ...
                   'gui_OutputFcn',  @dialog_box_OutputFcn, ...
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


% --- Executes just before dialog_box is made visible.
function dialog_box_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dialog_box (see VARARGIN)

% Choose default command line output for dialog_box
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dialog_box wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dialog_box_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Cy3Threshold_Callback(hObject, eventdata, handles)
% hObject    handle to Cy3Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Cy3Threshold as text
%        str2double(get(hObject,'String')) returns contents of Cy3Threshold as a double


% --- Executes during object creation, after setting all properties.
function Cy3Threshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Cy3Threshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FITCthreshold_Callback(hObject, eventdata, handles)
% hObject    handle to FITCthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FITCthreshold as text
%        str2double(get(hObject,'String')) returns contents of FITCthreshold as a double


% --- Executes during object creation, after setting all properties.
function FITCthreshold_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FITCthreshold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imageDirectory.
function imageDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to imageDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imgdir = uigetdir();
set(handles.txtImageDirectory, 'string', imgdir);


% --- Executes on button press in outputDirectory.
function outputDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to outputDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
outdir = uigetdir();
set(handles.txtOutputDirectory, 'string', outdir);



% --- Executes on button press in run.
function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
imagefolder = get(handles.txtImageDirectory, 'string');
outfolder = get(handles.txtOutputDirectory, 'string');
Cy3threshold = str2double(get(handles.Cy3Threshold, 'string'));
FITCthreshold = str2double(get(handles.FITCthreshold, 'string'));
if strcmp(imagefolder, 'Select Image Directory') || strcmp(outfolder, 'Select Data Output Directory') || isnan(Cy3threshold) || isnan(FITCthreshold)
    errordlg('All fields are required');
else
    cross_section_staining_analysis(imagefolder, Cy3threshold, FITCthreshold, outfolder);
end
