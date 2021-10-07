close all
clc
clear

load('Mask.mat')
parpool('local',20);
parfor Day = 1:365
    
    Flag = ["Day","Night"];
    Year_Array = 2002:2020;
    NumYear = length(Year_Array);
    
    for DayNight = 1:2
        
        ERA5_LST_Name = ['/ERA5_LST_' char(Flag(DayNight)) ];
        ERA5_LST_Array = zeros(3600,7200,NumYear);
        ERA5_LST_Climate = NaN(3600,7200);
        
        for year = 1:NumYear
            
            Year = num2str(Year_Array(year));
            DataPath = ['/data2/home/yupei/ERA5_LST/Aqua/' Year '/'];
            FileName_List = dir([DataPath 'Aqua_ERA5_LST*.h5']);
            FileName = FileName_List(Day,1).name;
            ERA5_LST = h5read([DataPath FileName],ERA5_LST_Name);
            ERA5_LST_Array(:,:,year) = ERA5_LST;
            
        end
        
        %calculate ERA5_LST_Climate
        for row = 1:3600
            for col = 1:7200
                if Mask(row,col) == 0
                    continue
                else
                    ERA5_LST_Climate(row,col) = mean(ERA5_LST_Array(row,col,:),'omitnan');
                end
            end
        end
        
        dataset = ['/ERA5_LST_Climate_' char(Flag(DayNight)) ];
        filename = ['Aqua_ERA5_LST_Climate_',sprintf('%03d',Day),'.h5'];
        h5create(filename,dataset,[3600 7200],'Datatype','single','ChunkSize',[3600 7200],'Deflate',9);
        h5write(filename,dataset,single(ERA5_LST_Climate));
        
    end
    
end

delete(gcp('nocreate'));