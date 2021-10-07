close all
clc
clear

Year_Array = 2002:2020;
for year = 1:19
    
    Year = num2str(Year_Array(year));
    %DataPath
    DataPath = ['/data/pengzq/MODIS_LST/Terra_0.05Deg/' Year '/'];
    %CurrentPath
    CurrentPath = pwd;
    addpath([CurrentPath '/dineof-3.0/Scripts/IO']);
    addpath([CurrentPath '/Task']);
    %FileName
    FileName_List = dir([DataPath 'MOD11C1.*.hdf']);
    %Allocate Memory
    NumDay = length(FileName_List);
    dates = (1:NumDay);
    scale_factor = 0.02;
    load('Mask.mat')
    Flag = ["Day","Night"];
    
    %Day&Night
    for DayNight = 1:2
        LST_source = ['LST_' char(Flag(DayNight)) '_CMG'];
        QC_source = ['QC_' char(Flag(DayNight))];
        
        %******************************************************%
        %STEP1
        LST_Array = single(zeros(3600,7200,NumDay));
        mask = Mask;
        for i = 1:NumDay
            FileName = FileName_List(i,1).name;
            %disp(FileName)
            LST_origin = hdfread([DataPath FileName],LST_source);
            QC_origin = hdfread([DataPath FileName],QC_source);
            %Quality control
            QC_matrix = bitget(QC_origin,8)==0;
            LST = single(LST_origin).*QC_matrix;
            LST(LST == 0) = NaN;
            LST_Array(:,:,i) = scale_factor*LST;
        end
        disp('Data reading completed...')
        
        
        %Divide into blocks
        ROW = 100*ones(1,36);
        COL = 100*ones(1,72);
        LST_Array_cell = mat2cell(LST_Array,ROW,COL,NumDay);
        mask_cell = mat2cell(mask,ROW,COL);
        clear LST_Array
        %Number
        T = 36*72;
        T1 = 1:T;
        T2 = reshape(T1,72,36);
        T3 = T2';
        mkdir('Original_Data')
        for row = 1:36
            for col = 1:72
                Number = T3(row,col);
                N = sprintf('%04d',Number);
                LST_Chunk = LST_Array_cell{row,col};
                mask_Chunk = mask_cell{row,col};
                gwrite(sprintf('LST_Chunk%s.dat',N),LST_Chunk);
                gwrite(sprintf('mask_Chunk%s.dat',N),mask_Chunk);
                movefile(sprintf('LST_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
                movefile(sprintf('mask_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
            end
        end
        clear LST_Array_cell mask_cell
        disp('Divided into blocks')
        
        
        Original_Path = [CurrentPath,'/Original_Data/'];
        LST_name = fullfile(Original_Path,'LST_Chunk*');
        mask_name = fullfile(Original_Path,'mask_Chunk*');
        LST_list = dir(LST_name);
        mask_list = dir(mask_name);
        %Find resource
        sched = parcluster();
        %Create job
        job = createJob(sched);
        %Create tasks
        createTask(job,@dineof0101,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0102,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0103,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0104,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0105,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0106,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0107,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0108,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0109,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0110,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0111,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0112,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        submit(job);
        wait(job);
        
        disp('Step1 run successfully')
        rmdir('Original_Data', 's')
        
        
        %********************************%
        %********************************%
        %Consolidate data
        %worker1-8 data
        for worker = 1:8
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(3,72,NumDay);
            for Hang = 1:3
                m = Hang*72;
                for j = m-71:m
                    n = j-(Hang-1)*72;
                    result_filename = List(j,1).name;
                    filled_cell = gread([Result_path result_filename]);
                    Filled{Hang,n} = filled_cell;
                end
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end
        %worker9 data
        Result_path = [CurrentPath,'/Output9/'];
        Result_name = fullfile(Result_path,'MODIS_Filled*');
        List = dir(Result_name);
        Filled = cell(9,72,NumDay);
        for Hang = 1:9
            m = Hang*72;
            for j = m-71:m
                n = j-(Hang-1)*72;
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{Hang,n} = filled_cell;
            end
        end
        eval(['LST_DINEOF9',' = ','cell2mat(Filled);']);
        rmdir('Output9', 's')
        clear Filled
        %worker10-12 data
        for worker = 10:12
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(1,72,NumDay);
            for j = 1:72
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{1,j} = filled_cell;
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end      
        %********************************%
        %********************************%
        
        mkdir('LST_DINEOF')
        for j = 1:NumDay
            N1 = sprintf('%03d',j);
            Filled_LST = cell(12,1);
            for part = 1:12
                eval(['LTS_Part',' = ','LST_DINEOF',num2str(part),'(:,:,',num2str(j),');']);
                Filled_LST{part,1} = LTS_Part;
            end
            LST_DINEOF_1 = cell2mat(Filled_LST);
            save(sprintf('LST_DINEOF%s.mat',N1),'LST_DINEOF_1')
            movefile(sprintf('LST_DINEOF%s.mat',N1),[CurrentPath '/LST_DINEOF']);
            clear Filled_LST
        end
        
        clearvars -except Year_Array year Year DataPath CurrentPath FileName_List NumDay...
            dates scale_factor Flag DayNight Mask LST_source QC_source
        
        
        %******************************************************%
        %STEP2
        
        LST_Array = single(zeros(3600,7100,NumDay));
        mask = Mask(1:3600,51:7150);
        for i = 1:NumDay
            FileName = FileName_List(i,1).name;
            LST_origin = hdfread([DataPath FileName],LST_source);
            QC_origin = hdfread([DataPath FileName],QC_source);
            %Quality control
            LST_part = LST_origin(1:3600,51:7150);
            QC_part = QC_origin(1:3600,51:7150);
            QC_matrix = bitget(QC_part,8)==0;
            LST = single(LST_part).*QC_matrix;
            %
            LST(LST == 0) = NaN;
            LST_Array(:,:,i) = scale_factor*LST;
        end
        disp('Data reading completed...')
        
        %Divide into blocks
        ROW = 100*ones(1,36);
        COL = 100*ones(1,71);
        LST_Array_cell = mat2cell(LST_Array,ROW,COL,NumDay);
        mask_cell = mat2cell(mask,ROW,COL);
        clear LST_Array
        %Number
        T = 36*71;
        T1 = 1:T;
        T2 = reshape(T1,71,36);
        T3 = T2';
        mkdir('Original_Data')
        for row = 1:36
            for col = 1:71
                Number = T3(row,col);
                N = sprintf('%04d',Number);
                LST_Chunk = LST_Array_cell{row,col};
                mask_Chunk = mask_cell{row,col};
                gwrite(sprintf('LST_Chunk%s.dat',N),LST_Chunk);
                gwrite(sprintf('mask_Chunk%s.dat',N),mask_Chunk);
                movefile(sprintf('LST_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
                movefile(sprintf('mask_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
            end
        end
        clear LST_Array_cell mask_cell
        disp('Divided into blocks')
        
        
        Original_Path = [CurrentPath,'/Original_Data/'];
        LST_name = fullfile(Original_Path,'LST_Chunk*');
        mask_name = fullfile(Original_Path,'mask_Chunk*');
        LST_list = dir(LST_name);
        mask_list = dir(mask_name);
        %Find resource
        sched = parcluster();
        %Create job
        job = createJob(sched);
        %Create tasks
        createTask(job,@dineof0201,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0202,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0203,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0204,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0205,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0206,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0207,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0208,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0209,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0210,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0211,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0212,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        submit(job);
        wait(job);
        
        disp('Step2 run successfully')
        rmdir('Original_Data', 's')
        
        
        %********************************%
        %********************************%
        %Consolidate data
        %worker1-8 data
        for worker = 1:8
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(3,71,NumDay);
            for Hang = 1:3
                m = Hang*71;
                for j = m-70:m
                    n = j-(Hang-1)*71;
                    result_filename = List(j,1).name;
                    filled_cell = gread([Result_path result_filename]);
                    Filled{Hang,n} = filled_cell;
                end
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end
        %worker9 data
        Result_path = [CurrentPath,'/Output9/'];
        Result_name = fullfile(Result_path,'MODIS_Filled*');
        List = dir(Result_name);
        Filled = cell(9,71,NumDay);
        for Hang = 1:9
            m = Hang*71;
            for j = m-70:m
                n = j-(Hang-1)*71;
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{Hang,n} = filled_cell;
            end
        end
        eval(['LST_DINEOF9',' = ','cell2mat(Filled);']);
        rmdir('Output9', 's')
        clear Filled
        %worker10-12 data
        for worker = 10:12
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(1,71,NumDay);
            for j = 1:71
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{1,j} = filled_cell;
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end      
        %********************************%
        %********************************%
        mkdir('LST_DINEOF_ROW')
        for j = 1:NumDay
            N1 = sprintf('%03d',j);
            Filled_LST = cell(12,1);
            for part = 1:12
                eval(['LTS_Part',' = ','LST_DINEOF',num2str(part),'(:,:,',num2str(j),');']);
                Filled_LST{part,1} = LTS_Part;
            end
            LST_DINEOF_2 = cell2mat(Filled_LST);
            save(sprintf('LST_DINEOF_ROW%s.mat',N1),'LST_DINEOF_2')
            movefile(sprintf('LST_DINEOF_ROW%s.mat',N1),[CurrentPath '/LST_DINEOF_ROW']);
            clear Filled_LST
        end
        
        
        clearvars -except Year_Array year Year DataPath CurrentPath FileName_List NumDay...
            dates scale_factor Flag DayNight Mask LST_source QC_source
        
        %******************************************************%
        %STEP3

        LST_Array = single(zeros(3500,7200,NumDay));
        mask = Mask(51:3550,1:7200);
        for i = 1:NumDay
            FileName = FileName_List(i,1).name;
            LST_origin = hdfread([DataPath FileName],LST_source);
            QC_origin = hdfread([DataPath FileName],QC_source);
            %Quality control
            LST_part = LST_origin(51:3550,1:7200);
            QC_part = QC_origin(51:3550,1:7200);
            QC_matrix = bitget(QC_part,8)==0;
            LST = single(LST_part).*QC_matrix;
            %
            LST(LST == 0) = NaN;
            LST_Array(:,:,i) = scale_factor*LST;
        end
        disp('Data reading completed...')
        
        
        %Divide into blocks
        ROW = 100*ones(1,35);
        COL = 100*ones(1,72);
        LST_Array_cell = mat2cell(LST_Array,ROW,COL,NumDay);
        mask_cell = mat2cell(mask,ROW,COL);
        clear LST_Array
        %Number
        T = 35*72;
        T1 = 1:T;
        T2 = reshape(T1,72,35);
        T3 = T2';
        mkdir('Original_Data')
        for row = 1:35
            for col = 1:72
                Number = T3(row,col);
                N = sprintf('%04d',Number);
                LST_Chunk = LST_Array_cell{row,col};
                mask_Chunk = mask_cell{row,col};
                gwrite(sprintf('LST_Chunk%s.dat',N),LST_Chunk);
                gwrite(sprintf('mask_Chunk%s.dat',N),mask_Chunk);
                movefile(sprintf('LST_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
                movefile(sprintf('mask_Chunk%s.dat',N),[CurrentPath '/Original_Data']);
            end
        end
        clear LST_Array_cell mask_cell
        disp('Divided into blocks')
        
        
        Original_Path = [CurrentPath,'/Original_Data/'];
        LST_name = fullfile(Original_Path,'LST_Chunk*');
        mask_name = fullfile(Original_Path,'mask_Chunk*');
        LST_list = dir(LST_name);
        mask_list = dir(mask_name);
        %Find resource
        sched = parcluster();
        %Create job
        job = createJob(sched);
        %Create tasks
        createTask(job,@dineof0301,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0302,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0303,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0304,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0305,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0306,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0307,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0308,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0309,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0310,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0311,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        createTask(job,@dineof0312,1,{Original_Path,LST_list,mask_list,dates,CurrentPath});
        submit(job);
        wait(job);
        
        disp('Step3 run successfully')
        rmdir('Original_Data', 's')
        
        
        %********************************%
        %********************************%
        %Consolidate data
        %worker1-8 data
        for worker = 1:8
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(3,72,NumDay);
            for Hang = 1:3
                m = Hang*72;
                for j = m-71:m
                    n = j-(Hang-1)*72;
                    result_filename = List(j,1).name;
                    filled_cell = gread([Result_path result_filename]);
                    Filled{Hang,n} = filled_cell;
                end
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end
        %worker9 data
        Result_path = [CurrentPath,'/Output9/'];
        Result_name = fullfile(Result_path,'MODIS_Filled*');
        List = dir(Result_name);
        Filled = cell(8,72,NumDay);
        for Hang = 1:8
            m = Hang*72;
            for j = m-71:m
                n = j-(Hang-1)*72;
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{Hang,n} = filled_cell;
            end
        end
        eval(['LST_DINEOF9',' = ','cell2mat(Filled);']);
        rmdir('Output9', 's')
        clear Filled
        %worker10-12 data
        for worker = 10:12
            Result_path = [CurrentPath,'/Output',num2str(worker),'/'];
            Result_name = fullfile(Result_path,'MODIS_Filled*');
            List = dir(Result_name);
            Filled = cell(1,72,NumDay);
            for j = 1:72
                result_filename = List(j,1).name;
                filled_cell = gread([Result_path result_filename]);
                Filled{1,j} = filled_cell;
            end
            eval(['LST_DINEOF',num2str(worker),' = ','cell2mat(Filled);']);
            rmdir(sprintf('Output%d',worker), 's')
            clear Filled
        end      
        %********************************%
        %********************************%
        
        mkdir('LST_DINEOF_COL')
        for j = 1:NumDay
            N1 = sprintf('%03d',j);
            Filled_LST = cell(12,1);
            for part = 1:12
                eval(['LTS_Part',' = ','LST_DINEOF',num2str(part),'(:,:,',num2str(j),');']);
                Filled_LST{part,1} = LTS_Part;
            end
            LST_DINEOF_3 = cell2mat(Filled_LST);
            save(sprintf('LST_DINEOF_COL%s.mat',N1),'LST_DINEOF_3')
            movefile(sprintf('LST_DINEOF_COL%s.mat',N1),[CurrentPath '/LST_DINEOF_COL']);
            clear Filled_LST
        end
        
        
        clearvars -except Year_Array year Year DataPath CurrentPath FileName_List NumDay...
            dates scale_factor Flag DayNight Mask LST_source QC_source
        
        %******************************************************%
        %STEP4
        List1 = dir([CurrentPath  '/LST_DINEOF/' 'LST_DINEOF*.mat']);
        List2 = dir([CurrentPath  '/LST_DINEOF_ROW/' 'LST_DINEOF_ROW*.mat']);
        List3 = dir([CurrentPath  '/LST_DINEOF_COL/' 'LST_DINEOF_COL*.mat']);
        load('QC.mat')
        mask = Mask;
        mask(mask == 0) = nan;
        mask(mask == 1) = 0;
        for Day = 1:NumDay
            
            Name1 = List1(Day,1).name;
            Name2 = List2(Day,1).name;
            Name3 = List3(Day,1).name;
            load([CurrentPath  '/LST_DINEOF/' Name1])
            load([CurrentPath  '/LST_DINEOF_ROW/' Name2])
            load([CurrentPath  '/LST_DINEOF_COL/' Name3])
            
            LST_complete = LST_DINEOF_1;
            %ROW
            LST_row = LST_DINEOF_2;
            %COL
            LST_col = LST_DINEOF_3;
            LST1 = LST_complete;
            LST_Part1 = LST_complete(1:3600,51:7150);
            LST_Slide1 = (LST_row+LST_Part1)/2;
            LST1(1:3600,51:7150) = LST_Slide1;
            LST2 = LST_complete;
            LST_Part2 = LST_complete(51:3550,1:7200);
            LST_Slide2 = (LST_col+LST_Part2)/2;
            LST2(51:3550,1:7200) = LST_Slide2;
            %LST final data
            LST_Sliding_window = (LST1+LST2)/2;
            LST_final = single(round(LST_Sliding_window,2));
            
            %Write data
            FileName = FileName_List(Day,1).name;
            filename = [FileName(1:16) '.h5'];
            dataset1 = ['/LST_' char(Flag(DayNight)) '_CMG'];
            dataset2 = ['/QC_' char(Flag(DayNight))];
            dataset3 = ['/' char(Flag(DayNight)) '_view_time'];
            dataset4 = ['/' char(Flag(DayNight)) '_view_angl'];
            
            %LST
            h5create(filename,dataset1,[3600 7200],'Datatype','single','ChunkSize',[3600 7200],'Deflate',9);
            h5write(filename,dataset1,LST_final);
            %QC
            d2 = hdfread([DataPath FileName],['QC_' char(Flag(DayNight))]);
            QC1 = double(bitget(d2,8)==0);
            QC2 = QC1+mask;
            QC2(isnan(QC2)) = 0;
            QC2(QC2 == 1) = nan;
            QC3 = QC2+QC;
            QC3(isnan(QC3)) = 1;
            QC4 = uint8(QC3);
            h5create(filename,dataset2,[3600 7200],'Datatype','uint8','ChunkSize',[3600 7200],'Deflate',9);
            h5write(filename,dataset2,QC4);
            %View_time
            d3 = hdfread([DataPath FileName],[char(Flag(DayNight)) '_view_time']);
            h5create(filename,dataset3,[3600 7200],'Datatype','uint8','ChunkSize',[3600 7200],'Deflate',9);
            h5write(filename,dataset3,d3);
            %View_angl
            d4 = hdfread([DataPath FileName],[char(Flag(DayNight)) '_view_angl']);
            h5create(filename,dataset4,[3600 7200],'Datatype','uint8','ChunkSize',[3600 7200],'Deflate',9);
            h5write(filename,dataset4,d4);
            
        end
        
        rmdir('LST_DINEOF', 's')
        rmdir('LST_DINEOF_ROW', 's')
        rmdir('LST_DINEOF_COL', 's')
        clearvars -except Year_Array year Year DataPath CurrentPath FileName_List NumDay...
            dates scale_factor Flag DayNight Mask LST_source QC_source
        %******************************************************%
    end
    
    %MoveFile
    mkdir(Year)
    FileList = dir([CurrentPath '/' 'MOD11C1.*.h5']);
    for NUM = 1:NumDay
        file = FileList(NUM,1).name;
        movefile([CurrentPath '/' file],[CurrentPath '/' Year]);
    end
    
    %******************************************************%
    fprintf('%s processing completed...\n',Year)
    
    clearvars -except Year_Array year
end
disp('**********Carry out**********')