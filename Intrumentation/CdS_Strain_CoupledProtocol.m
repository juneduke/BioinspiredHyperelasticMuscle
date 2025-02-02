%CdS Protocol
%%
clear;
clc;

function daqval=daqreadout(d,basev,bases)
data = read(d);
k=timetable2table(data);
daqval(1) = (k.(2))*2.748763056624519-basev;
daqval(2) = (k.(3))*0.59382423-bases;
daqval(3) = (k.(4));
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

%% Experimental Conditions
fiberL=50;

%% SET FILENAME

filename = 'filename';

%%

Time=NaN(1,10000000);
Strain=NaN(1,10000000);
Volume =NaN(1,10000000);
Optical =NaN(1,10000000);


d = daq("ni");
d.Rate=2000000;
addinput(d,"Dev2",[1 7 18],"Voltage");
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
bx3.YLabel.String='Optical(V)';
h1=line('XData',[],'YData',[],'Parent', bx1);
h2=line('XData',[],'YData',[],'Parent', bx2);
h3=line('XData',[],'YData',[],'Parent', bx3);
[h0,m0,s0] =hms(datetime("now"));
t0=3600*h0+60*m0+s0;

data=[];



for i=1:1:100
    v = daqreadout(d,0,0);
    volume = v(1);
    strain = v(2);
    Optical_Intensity=v(3);
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
        Volume(i)=v(1);
        Strain(i) = v(2);
        Optical(i) = v(3);
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


