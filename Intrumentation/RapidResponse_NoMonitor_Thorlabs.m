%AM Recording Protocol-Realtime Monitoring/Recording
%%
clear;
clc;

function opticalI=OIread(test_meter)
test_meter.updateReading(0.001);
opticalI = test_meter.meterPowerReading;
end

function daqval=daqreadout(d,basev,bases)
data = read(d);
k=timetable2table(data);
daqval(1) = (k.(2))*2.748763056624519-basev;
daqval(2) = (k.(3))*0.59382423-bases;
end

function realplot(Time,Volume,Strain,Optical,h1,h2,h3,bx1,bx2,bx3,n)

if n>1000
    if rem(n,10)==0


        h1.XData=Time(n-999:1:n);
        h2.XData=Time(n-999:1:n);
        h3.XData=Time(n-999:1:n);

        h1.YData=Volume(n-999:n);
        h2.YData=Strain(n-999:n);
        h3.YData=Optical(n-999:n);

        bx1.XLim=[Time(n-999) Time(n)];
        bx2.XLim=[Time(n-999) Time(n)];
        bx3.XLim=[Time(n-999) Time(n)];


        drawnow limitrate;
    end


else

    if rem(n,10)==0

        h1.XData=Time(1:1:n);
        h2.XData=Time(1:1:n);
        h3.XData=Time(1:1:n);

        h1.YData=Volume(1:n);
        h2.YData=Strain(1:n);
        h3.YData=Optical(1:n);

        bx1.XLim=[Time(1) Time(n)];
        bx2.XLim=[Time(1) Time(n)];
        bx3.XLim=[Time(1) Time(n)];

        drawnow limitrate;

    end

end



end
%%
addpath("DriverPath");


delete(instrfind);

meter_list=ThorlabsPowerMeter;                              % Initiate the meter_list
DeviceDescription=meter_list.listdevices;               	% List available device(s)
test_meter=meter_list.connect(DeviceDescription);           % Connect single/the first devices
test_meter.setWaveLength(635);                              % Set sensor wavelength
test_meter.setDispBrightness(0.3);                          % Set display brightness
test_meter.setAttenuation(0);                               % Set Attenuation
test_meter.sensorInfo;                                      % Retrive the sensor info
test_meter.setPowerAutoRange(1);                            % Set Autorange
pause(5)                                                    % Pause the program a bit to allow the power meter to autoadjust
test_meter.setAverageTime(0.01);                            % Set average time for the measurement
test_meter.setTimeout(1000);                                % Set timeout value

%% Experimental Conditions
fiberL=50;

%% SET FILENAME

filename = 'Filename';

%%

Time=NaN(1,10000000);
Strain=NaN(1,10000000);
Volume =NaN(1,10000000);
Optical =NaN(1,10000000);

d = daq("ni");
d.Rate=2000000;
addinput(d,"Dev2",[1 7],"Voltage");
c=0;

f=uifigure;
set(f, 'Position', get(0, 'Screensize'));
p1 = uipanel(f, 'Position', [10 10 1910 1070]);
ax = uiaxes(p1, 'Position', [150 150 1860 1020]);
ax.XGrid = 'on';
ax.YGrid = 'on';
p1.AutoResizeChildren = 'off';
b=uibutton(p1, "state","Text","Stop","Position",[10 10 120 120]);
bx1=subplot(3,1,1, 'Parent', p1);
bx2=subplot(3,1,2, 'Parent', p1);
bx3=subplot(3,1,3, 'Parent', p1);


bx1.YLabel.String='Volume(mL)';
bx2.YLabel.String='Strain(mm)';
bx3.YLabel.String='Optical(mW)';
h1=line('XData',[],'YData',[],'Parent', bx1);
h2=line('XData',[],'YData',[],'Parent', bx2);
h3=line('XData',[],'YData',[],'Parent', bx3);
[h0,m0,s0] =hms(datetime("now"));
t0=3600*h0+60*m0+s0;

data=[];



for i=1:1:20
    v = daqreadout(d,0,0);
    volume = v(1);
    strain = v(2);
    Optical_Intensity=OIread(test_meter);
    Volume(i)=volume;
    Strain(i) = strain;
    Optical(i) = Optical_Intensity;
end
basevolume=mean(Volume(~isnan(Volume)));
basestrain=mean(Strain(~isnan(Strain)));
baseoptical=mean(Optical_Intensity(~isnan(Optical_Intensity)));

%% REINITIALIZE
profile on;
Time=NaN(1,10000000);
Strain=NaN(1,10000000);
Volume =NaN(1,10000000);
Optical =NaN(1,10000000);
num_no_nans=0;
i=1;

device2 = serialport("COM14",9600);
r=readline(device2);
write(device2,1,"uint8");

tic;

try
    while (c==0)

        t=toc;
        v = daqreadout(d,basevolume,basestrain);
        Volume(i)=(v(1));
        Strain(i) = (v(2));
        Optical(i) = OIread(test_meter);
        Time(i) = t;
        i=i+1;
        num_no_nans = sum(~isnan(Time(1,:)));
        realplot(Time,Volume,Strain,Optical,h1,h2,h3,bx1,bx2,bx3,num_no_nans);
        c=b.Value;
    end
    Volume=Volume(~isnan(Volume));
    Time=Time(~isnan(Time));

    Strain=Strain(~isnan(Strain));
    Optical=Optical(~isnan(Optical));

    i=0;
    fn=strcat(filename,'.csv');
    FFN="";
    if isfile(fn)
        FFN=filename;
        while (isfile(fn))

            i=i+1;
            num=strcat('(',num2str(i),')');
            FFN=strcat(filename,num);
            fn=strcat(FFN,'.csv');
        end
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume,Strain, Optical);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume, Strain, Optical);

        writetable(T, FFN);

    end

    profile viewer;

catch
    Volume=Volume(~isnan(Volume));
    Time=Time(~isnan(Time));
    Strain=Strain(~isnan(Strain));
    Optical=Optical(~isnan(Optical));

    i=0;
    filename=strcat(filename,'errortempsave');
    fn=strcat(filename,'.csv');
    FFN="";
    if isfile(fn)
        FFN=filename;
        while (isfile(fn))

            i=i+1;
            num=strcat('(',num2str(i),')');
            FFN=strcat(filename,num);
            fn=strcat(FFN,'.csv');
        end
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume, Strain, Optical);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume, Strain, Optical);

        writetable(T, FFN);

    end
    warning("An error has occurred, any data that existe has been now saved under the name:filename+errortempsave.csv/.m");
    delete(device);
    pause(1);

    warning("The Program will now attempt to stop the Arduino");
    try
        device2 = serialport("COM14",9600);
        configureTerminator(device2,"CR");
        disp("All errors have been dealt with: DATA is safely stored, Arduino has been stopped");
    catch
        disp("Failure: Program has failed to shut down arduino, please manually switch power off");
    end


end

