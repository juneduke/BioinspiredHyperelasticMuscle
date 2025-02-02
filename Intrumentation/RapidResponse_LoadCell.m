clear;
clc;
c=0;
filename = 'Filename';
function h=decode(x)
ch=['30';'31';'32';'33';'34';'35';'36';'37';'38';'39';'3A';'3B';'3C';'3D';'3E';'3F'];
p=dec2hex(x);

if(p(3,1)=='-')
    h=0.001*(0- (find(p(3,2)==ch(:,2))*16^4+find(p(4,2)==ch(:,2))*16^3+find(p(5,2)==ch(:,2))*16^2+find(p(6,2)==ch(:,2))*16+find(p(7,2)==ch(:,2))-16^4-16^3-16^2-16));
else
    h=0.001*((find(p(3,2)==ch(:,2))*16^4+find(p(4,2)==ch(:,2))*16^3+find(p(5,2)==ch(:,2))*16^2+find(p(6,2)==ch(:,2))*16+find(p(7,2)==ch(:,2)))-16^4-16^3-16^2-16);
end 
end

function force=readload(device,baseload)

    ReadForce=convertStringsToChars(readline(device));
    force=decode(ReadForce)-baseload;
end


f=uifigure;
p1 = uipanel(f, 'Position', [10 10 510 570]);
ax = uiaxes(p1, 'Position', [150 150 500 220]);
ax.XGrid = 'on';
ax.YGrid = 'on';
p1.AutoResizeChildren = 'off';
b=uibutton(p1, "state","Text","Stop","Position",[10 10 120 120]);
h1=line('XData',[],'YData',[],'Parent', ax);


device = serialport("COM7",2400,"DataBits",8,"Timeout",10);
configureTerminator(device,85,"LF");

write(device,'e',"char");
pause(1);
i=1;

Time=NaN(1,10000000);
Load=NaN(1,10000000);
read(device,device.NumBytesAvailable,"char");
readline(device);
tic;
while (c==0)
    pause(0.05);
    t=toc;
    foad=readload(device,0);
    Load(i)=foad;
    Time(i) = t;

    i=i+1;
    num_no_nans = sum(~isnan(Time(1,:)));

    if(i>2)

            h1.XData=Time(1:num_no_nans);
            h1.YData=Load(1:num_no_nans);
            ax.XLim=[Time(1) Time(num_no_nans)];
    drawnow limitrate;
    c=b.Value;
    end
end
Time=Time(~isnan(Time));
Load=Load(~isnan(Load));

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

        T=table(Time,Load);
        writetable(T, FFN);

    else

        FFN=filename;
        save(FFN);

        FFN=strcat(FFN,'.csv');

        T=table(Time,Load);

        writetable(T, FFN);

    end