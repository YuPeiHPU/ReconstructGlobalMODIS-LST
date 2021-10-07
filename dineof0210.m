function LST_DINEOF10 = dineof0210(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output10')
for Chunk = 2344:2414
        
        N = sprintf('%04d',Chunk);
        FileName1 = LST_list(Chunk,1).name;
        FileName2 = mask_list(Chunk,1).name;
        LST_Chunk = gread([Original_Path FileName1]);
        mask_Chunk = gread([Original_Path FileName2]);
        
        gwrite('MODIS_LST10.dat',single(LST_Chunk));
        gwrite('MODIS_mask10.dat',single(mask_Chunk));
        gwrite('MODIS_dates10.dat',single(dates));
        
        if mask_Chunk == 0
            movefile(sprintf('MODIS_LST10.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output10']);
            delete('MODIS_mask10.dat');
            delete('MODIS_dates10.dat');
            continue
        else
            cd (CurrentPath);
            system('./dineof-10.0-x64-linux dineof10.init')
            
            if exist([CurrentPath '/Output10/' 'MODIS_Filled.filled'],'file') == 0
                movefile(sprintf('MODIS_LST10.dat'),sprintf('MODIS_Filled_%s.dat',N));
                movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output10']);
                delete('MODIS_mask10.dat');
                delete('MODIS_dates10.dat');
            else
                movefile([CurrentPath '/Output10/' 'MODIS_Filled.filled'],[CurrentPath '/Output10/' sprintf('MODIS_Filled_%s.filled',N)]);
                delete('MODIS_LST10.dat');
                delete('MODIS_mask10.dat');
                delete('MODIS_dates10.dat');
            end
            
            cd (CurrentPath);
            
        end
end

LST_DINEOF10 = 0110;

end