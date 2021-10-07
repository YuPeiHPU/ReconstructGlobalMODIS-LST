close all
clc
clear

load('Mask.mat')
CurrentPath = pwd;
Year_Array = 2002:2020;
NumYear = length(Year_Array);

for year = 1:NumYear
    
    Flag = ["Day","Night"];
    Year = num2str(Year_Array(year));
    MODIS_LST_Path = ['/data2/home/yupei/Filled_MODIS_LST/Terra/' Year '/'];
    MODIS_LST_Climate_Path = '/data2/home/yupei/Filled_MODIS_LST_Climate/Terra/';
    ERA5_LST_Path = ['/data2/home/yupei/ERA5_LST/Terra/' Year '/'];
    ERA5_LST_Climate_Path = '/data2/home/yupei/ERA5_LST_Climate/Terra/';
    Original_MODIS_Path = ['/data2/home/yupei/MODIS_LST/Terra_0.05Deg/' Year '/'];
    MODIS_LST_List = dir([MODIS_LST_Path 'MOD11C1.*.h5']);
    MODIS_LST_Climate_List = dir([MODIS_LST_Climate_Path 'Terra_LST_Climate*.h5']);
    ERA5_LST_List = dir([ERA5_LST_Path 'Terra_ERA5_LST*.h5']);
    ERA5_LST_Climate_List = dir([ERA5_LST_Climate_Path 'Terra_ERA5_LST_Climate*.h5']);
    Original_MODIS_List = dir([Original_MODIS_Path 'MOD11C1.*.hdf']);
    
    NumDay = length(Original_MODIS_List);
    if NumDay == 365
        MODIS_LST_Climate_List(60,:) = [];
        ERA5_LST_Climate_List(60,:) = [];
    end
    
    for DayNight = 1:2
        
        MODIS_LST_Array = single(NaN(3600,7200,NumDay));
        MODIS_LST_Climate_Array = single(NaN(3600,7200,NumDay));
        ERA5_LST_Array = single(NaN(3600,7200,NumDay));
        ERA5_LST_Climate_Array = single(NaN(3600,7200,NumDay));
        Original_MODIS_Array = single(NaN(3600,7200,NumDay));
        Corrected_LST_Array = single(NaN(3600,7200,NumDay));
        
        MODIS_LST_DataSet = ['/LST_' char(Flag(DayNight)) '_CMG'];
        MODIS_LST_Climate_DataSet = ['/LST_Climate_' char(Flag(DayNight)) ];
        ERA5_LST_DataSet = ['/ERA5_LST_' char(Flag(DayNight)) ];
        ERA5_LST_Climate_DataSet = ['/ERA5_LST_Climate_' char(Flag(DayNight)) ];
        Original_MODIS_DataSet = ['LST_' char(Flag(DayNight)) '_CMG'];
        
        %Read data
        for i = 1:NumDay
            MODIS_LST_File = MODIS_LST_List(i,1).name;
            MODIS_LST_Climate_File = MODIS_LST_Climate_List(i,1).name;
            ERA5_LST_File = ERA5_LST_List(i,1).name;
            ERA5_LST_Climate_File = ERA5_LST_Climate_List(i,1).name;
            Original_MODIS_File = Original_MODIS_List(i,1).name;
            
            MODIS_LST = h5read([MODIS_LST_Path MODIS_LST_File],MODIS_LST_DataSet);
            MODIS_LST_Array(:,:,i) = MODIS_LST;
            MODIS_LST_Climate = h5read([MODIS_LST_Climate_Path MODIS_LST_Climate_File],MODIS_LST_Climate_DataSet);
            MODIS_LST_Climate_Array(:,:,i) = MODIS_LST_Climate;
            ERA5_LST = h5read([ERA5_LST_Path ERA5_LST_File],ERA5_LST_DataSet);
            ERA5_LST_Array(:,:,i) = ERA5_LST;
            ERA5_LST_Climate = h5read([ERA5_LST_Climate_Path ERA5_LST_Climate_File],ERA5_LST_Climate_DataSet);
            ERA5_LST_Climate_Array(:,:,i) = ERA5_LST_Climate;
            Original_MODIS = single(hdfread([Original_MODIS_Path Original_MODIS_File],Original_MODIS_DataSet));
            Original_MODIS(Original_MODIS == 0) = NaN;
            Original_MODIS_Array(:,:,i) = Original_MODIS;
        end
        
        %CDF-matching
        
        for row = 1:3600
            for col = 1:7200
                
                if Mask(row,col) == 0
                    continue
                            
                else
                    %Correctify LST_Climate
                    D2 = find(isnan(ERA5_LST_Climate_Array(row,col,:)));
                    ERA5_LST_Climate_Array(row,col,D2) = MODIS_LST_Climate_Array(row,col,D2);
                    
                    MODIS_ERA5_Array = zeros(NumDay,3);
                    LST_Climate_clearDay = MODIS_LST_Climate_Array(row,col,:);
                    ERA5_Climate = ERA5_LST_Climate_Array(row,col,:);
                    Delta1 = mean(LST_Climate_clearDay,'omitnan') - mean(ERA5_Climate,'omitnan');
                    LST_Climate = LST_Climate_clearDay - Delta1;
                    MODIS_ERA5_Array(:,1) = MODIS_LST_Array(row,col,:) - LST_Climate;
                    MODIS_ERA5_Array(:,2) = ERA5_LST_Array(row,col,:) - ERA5_Climate;
                    MODIS_ERA5_Array(:,3) = Original_MODIS_Array(row,col,:);
                    [row1,~] = find(~isnan(MODIS_ERA5_Array(:,3)));
                    [row2,~] = find(isnan(MODIS_ERA5_Array(:,3)));
                    MODIS_ERA5_Array(row1,:) = [];
                    
                    Biased_data = MODIS_ERA5_Array(:,1);
                    Ref_data = MODIS_ERA5_Array(:,2);
                    Prob_ref = Prob_data(Ref_data)';
                    Prob_biased = Prob_data(Biased_data)';
                    Biased_interpolated = interp1(Prob_biased,sort(Biased_data),sort(Prob_ref),'linear','extrap');
                    p = polyfit(Biased_interpolated,sort(Ref_data)-Biased_interpolated,5);
                    Corrected_Bias = polyval(p,Biased_data)+ Biased_data;
                    
                    Delta2 = Biased_data - Corrected_Bias;
                    Corrected_Delta = zeros(NumDay,1);
                    Corrected_Delta(row2,:) = Delta2;
                    Corrected_LST = single(reshape(MODIS_LST_Array(row,col,:),[],1) - Corrected_Delta);
                    Corrected_LST_Array(row,col,:) = Corrected_LST;
                end
                
            end
        end
        
        clear MODIS_LST_Array MODIS_LST_Climate_Array ERA5_LST_Array ERA5_LST_Climate_Array Original_MODIS_Array
        
        for Day = 1:NumDay
            
            Corrected_Reconstructed_LST = Corrected_LST_Array(:,:,Day);
            dataset = ['/LST_' char(Flag(DayNight)) '_CMG'];
            filename = ['Terra_Corrected_LST_',Year,sprintf('%03d',Day),'.h5'];
            h5create(filename,dataset,[3600 7200],'Datatype','single','ChunkSize',[3600 7200],'Deflate',9);
            h5write(filename,dataset,single(Corrected_Reconstructed_LST));
            
        end
        
        clear Corrected_LST_Array
        
    end
    
    %MoveFile
    mkdir(Year)
    FileList = dir([CurrentPath '/' 'Terra_Corrected_LST*.h5']);
    for D = 1:NumDay
        file = FileList(D,1).name;
        movefile([CurrentPath '/' file],[CurrentPath '/' Year]);
    end
    
    fprintf('%s processing completed...\n',Year)
    
end