%Arm model Recording Protocol-Realtime Monitoring/Recording
%%
clear;
clc;

function daqval=daqreadout(d,basev1,basev2)
data = read(d);
k=timetable2table(data);
daqval(1) = (k.(2))*2.4197-basev1;
daqval(2) = (k.(4))*2.4197-basev2;
daqval(3) = 180*real(acos((k.(6)-1.69)/0.056))/3.141592;
daqval(4) = k.(3);
daqval(5) = k.(5);

end

function realplot(Time,V1,V2,Angle,O1,O2,h1,h2,h3,h4,h5,bx1,bx2,bx3,bx4,bx5,n)

if n>1000
    if rem(n,10)==0


        h1.XData=Time(n-999:1:n);
        h2.XData=Time(n-999:1:n);
        h3.XData=Time(n-999:1:n);
        h4.XData=Time(n-999:1:n);
        h5.XData=Time(n-999:1:n);
        
        
        h1.YData=Angle(n-999:n);
        
        h3.YData=O1(n-999:n);
        h2.YData=O2(n-999:n);

        h5.YData=V2(n-999:n);
        h4.YData=V1(n-999:n);

        bx1.XLim=[Time(n-999) Time(n)];
        bx2.XLim=[Time(n-999) Time(n)];
        bx3.XLim=[Time(n-999) Time(n)];
        bx4.XLim=[Time(n-999) Time(n)];
        bx5.XLim=[Time(n-999) Time(n)];


        drawnow limitrate;
    end


else

    if rem(n,10)==0

        h1.XData=Time(1:1:n);
        h2.XData=Time(1:1:n);
        h3.XData=Time(1:1:n);

        h4.XData=Time(1:1:n);
        h5.XData=Time(1:1:n);

        h1.YData=Angle(1:n);
        
        h3.YData=O1(1:n);
        h2.YData=O2(1:n);

        h5.YData=V2(1:n);
        h4.YData=V1(1:n);

        bx1.XLim=[Time(1) Time(n)];
        bx2.XLim=[Time(1) Time(n)];
        bx3.XLim=[Time(1) Time(n)];
        bx4.XLim=[Time(1) Time(n)];
        bx5.XLim=[Time(1) Time(n)];

        drawnow limitrate;

    end

end



end


%% SET FILENAME

filename = 'FILENAME';

%%

Time=NaN(1,10000000);
Angle=NaN(1,10000000);
VolumeBicep =NaN(1,10000000);
Optical_Bicep =NaN(1,10000000);
Optical_Tricep =NaN(1,10000000);
VolumeTricep =NaN(1,10000000);


d = daq("ni");
d.Rate=2000000;
addinput(d,"Dev2",[1 3 5 6 16],"Voltage");
addoutput(d,"Dev2",[0 1],"Voltage");
write(d, [1 1]);
c=0;


f=uifigure;
set(f, 'Position', get(0, 'Screensize'));
p1 = uipanel(f, 'Position', [10 10 1910 1070]);
ax = uiaxes(p1, 'Position', [150 150 1860 1020]);
ax.XGrid = 'on';
ax.YGrid = 'on';
p1.AutoResizeChildren = 'off';
b=uibutton(p1, "state","Text","Stop","Position",[10 10 120 120]);
bx1=subplot(3,2,[1 2], 'Parent', p1);
bx2=subplot(3,2,3, 'Parent', p1);
bx3=subplot(3,2,4, 'Parent', p1);
bx4=subplot(3,2,5, 'Parent', p1);
bx5=subplot(3,2,6, 'Parent', p1);


bx1.YLabel.String='Arm Position(degrees)';
bx2.YLabel.String='BicepOptical(V)';
bx3.YLabel.String='TricepOptical(V)';
bx4.YLabel.String='BicepVolume(mL)';
bx5.YLabel.String='TricepVolume(mL)';

h1=line('XData',[],'YData',[],'Parent', bx1);
h2=line('XData',[],'YData',[],'Parent', bx2);
h3=line('XData',[],'YData',[],'Parent', bx3);
h4=line('XData',[],'YData',[],'Parent', bx4);
h5=line('XData',[],'YData',[],'Parent', bx5);


[h0,m0,s0] =hms(datetime("now"));
t0=3600*h0+60*m0+s0;

data=[];



for i=1:1:100
    v = daqreadout(d,0,0);
    volume1 = v(1);
    volume2 = v(2);
    angle = v(3);
    Optical_Intensity_bicep=v(4);
    Optical_Intensity_tricep=v(5);
    
    VolumeBicep(i)=volume1;
    VolumeTricep(i)=volume2;
    Angle(i) = angle;
    Optical_Bicep(i) = Optical_Intensity_tricep;
    Optical_Tricep(i) = Optical_Intensity_bicep;
    
end
basevolumeBicep=mean(VolumeBicep(~isnan(VolumeBicep)));
basevolumeTricep=mean(VolumeTricep(~isnan(VolumeTricep)));
basestrain=mean(Angle(~isnan(Angle)));
baseoptical_bicep=mean(Optical_Bicep(~isnan(Optical_Bicep)));
baseoptical_tricep=mean(Optical_Tricep(~isnan(Optical_Tricep)));

%% REINITIALIZE
profile on;
Time=NaN(1,10000000);
Angle=NaN(1,10000000);
VolumeBicep =NaN(1,10000000);
VolumeTricep =NaN(1,10000000);

Optical_Bicep =NaN(1,10000000);
Optical_Tricep =NaN(1,10000000);

num_no_nans=0;
i=1;


tic;

try
    while (c==0)

        t=toc;
        v = daqreadout(d,basevolumeBicep,basevolumeTricep);
        volume1 = v(1);
        volume2 = v(2);
        angle = v(3);
        Optical_Intensity_bicep=v(4);
        Optical_Intensity_tricep=v(5);

        VolumeBicep(i)=volume1;
        VolumeTricep(i)=volume2;
        Angle(i) = angle;
        Optical_Bicep(i) = Optical_Intensity_tricep;
        Optical_Tricep(i) = Optical_Intensity_bicep;

        Time(i) = t;
        i=i+1;
        num_no_nans = sum(~isnan(Time(1,:)));
        realplot(Time,VolumeBicep,VolumeTricep,Angle,Optical_Tricep,Optical_Bicep,h1,h2,h3,h4,h5,bx1,bx2,bx3,bx4,bx5,num_no_nans);        
        c=b.Value;
    end
    VolumeBicep=VolumeBicep(~isnan(VolumeBicep));
    VolumeTricep=VolumeTricep(~isnan(VolumeTricep));

    Time=Time(~isnan(Time));

    Angle=Angle(~isnan(Angle));
    Optical_Bicep=Optical_Bicep(~isnan(Optical_Bicep));

    Optical_Tricep=Optical_Tricep(~isnan(Optical_Tricep));
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

        T=table(Time,VolumeBicep,VolumeTricep,Angle, Optical_Bicep,Optical_Tricep);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,VolumeBicep,VolumeTricep,Angle, Optical_Bicep,Optical_Tricep);

        writetable(T, FFN);

    end

    profile viewer;

catch
    VolumeBicep=VolumeBicep(~isnan(VolumeBicep));
    Time=Time(~isnan(Time));
    Angle=Angle(~isnan(Angle));
    Optical_Bicep=Optical_Bicep(~isnan(Optical_Bicep));

    Optical_Tricep=Optical_Tricep(~isnan(Optical_Tricep));
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

        T=table(Time,VolumeBicep,VolumeTricep,Angle, Optical_Bicep,Optical_Tricep);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');
        T=table(Time,VolumeBicep,VolumeTricep,Angle, Optical_Bicep,Optical_Tricep);

        writetable(T, FFN);

    end
    warning("An error has occurred, any data that existe has been now saved under the name:filename+errortempsave.csv/.m");
    pause(1);



end


