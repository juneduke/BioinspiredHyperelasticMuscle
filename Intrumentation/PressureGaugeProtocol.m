%Pressure Gauge Protocol
%%
clear;
clc;

%% SET FILENAME

filename = 'Filename';

%%
%delete(instrfind);

Time=[];
Pressure=[];
Volume = [];

basepressure=0;
basevolume=0;

d = daq("ni");

d.Rate=333333;
addinput(d,"Dev2",[1 3],"Voltage");
c=0;

f=uifigure;
p1 = uipanel(f, 'Position', [10 10 1010 1070]);
ax = uiaxes(p1, 'Position', [150 150 960 1020]);
ax.XGrid = 'on';
ax.YGrid = 'on';
p1.AutoResizeChildren = 'off';
b=uibutton(p1, "state","Text","Stop","Position",[10 10 120 120]);
bx1=subplot(2,1,1, 'Parent', p1);
bx2=subplot(2,1,2, 'Parent', p1);

bx1.YLabel.String='Volume(mL)';
bx2.YLabel.String='Pressure(V)';
h1=line('XData',[],'YData',[],'Parent', bx1);
h2=line('XData',[],'YData',[],'Parent', bx2);

[h0,m0,s0] =hms(datetime("now"));
t0=3600*h0+60*m0+s0;

data=[];

for i=1:1:100
    data=read(d);
    k=timetable2table(data);
    volume = k.(2);
    pressure=k.(3);

    Volume = [Volume; volume];
    Pressure = [Pressure;pressure];

end
basevolume=mean(Volume);
basepressure=mean(Pressure);

Pressure=[];
Volume = [];
tic;
try
    while (c==0)

        Rcvd='!';
        data = read(d);
        t=toc;

        k=timetable2table(data);
        volume = (k.(2)-basevolume);
        pressure=(k.(3)-basepressure);

        Time=[Time; t];
        Volume = [Volume; volume*2.748763056624519];
        Pressure = [Pressure;pressure*39.952*6.89476];

        if length(Time)>1000
            if rem(length(Time),10)==0


                h1.XData=Time(length(Volume)-999:1:length(Volume));
                h2.XData=Time(length(Pressure)-999:1:length(Pressure));

                h1.YData=Volume(end-999:end);
                h2.YData=Pressure(end-999:end);

                bx1.XLim=[Time(length(Volume)-999) Time(length(Volume))];
                bx2.XLim=[Time(length(Pressure)-999) Time(length(Pressure))];


                drawnow limitrate;
            end


        else

            if rem(length(Time),10)==0

                h1.XData=Time(1:1:length(Volume));
                h2.XData=Time(1:1:length(Pressure));

                h1.YData=Volume(1:end);
                h2.YData=Pressure(1:end);

                bx1.XLim=[Time(1) Time(length(Volume))];
                bx2.XLim=[Time(1) Time(length(Pressure))];

                drawnow limitrate;

            end

        end

        c=b.Value;

    end


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

        T=table(Time,Volume,Pressure);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume,Pressure);

        writetable(T, FFN);

    end

catch

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

        T=table(Time,Volume,Pressure);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Volume,Pressure);

        writetable(T, FFN);

        warning("An error has occurred, any data that existe has been now saved under the name:filename+errortempsave.csv/.m");
        delete(device);
        pause(1);


    end

end
