function Explode(~)

    f = figure('Position',[500,500,170,65], 'Name','ExplodePNAX','NumberTitle','off');
    title('Are you sure?');
    set(gcf, 'MenuBar', 'none');
    axis off;
    uicontrol('Style','pushbutton',...
                 'String','Yes','Position',[10,10,70,25]);
    uicontrol('Style','pushbutton',...
                 'String','No','Position',[90,10,70,25],...
                 'Callback',@(source,eventdata)nobutton_Callback(source,eventdata, f));

    set(gcf, 'WindowButtonMotionFcn', @mouseMove);

    function nobutton_Callback(source,eventdata, f) 
       msgbox('I know you are not serious :)');      
       close(f);
    end

    function mouseMove(object, eventdata)
        C = get(gcf, 'CurrentPoint');
        X = C(1,1);
        Y = C(1,2);
        
        if (X >= 10) && (X <= 80) && (Y >= 10) && (Y <= 35)
            set(gcf, 'Position',[randi([200,1000]),randi([100,800]),170,65]); 
        end
    end
end

