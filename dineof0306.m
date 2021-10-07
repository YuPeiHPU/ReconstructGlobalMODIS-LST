function LST_DINEOF6 = dineof0306(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output6')
for Chunk = 1081:1296
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST6.dat',single(LST_Chunk));
    gwrite('MODIS_mask6.dat',single(mask_Chunk));
    gwrite('MODIS_dates6.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST6.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output6']);
        delete('MODIS_mask6.dat');
        delete('MODIS_dates6.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-6.0-x64-linux dineof6.init')
        
        if exist([CurrentPath '/Output6/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST6.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output6']);
            delete('MODIS_mask6.dat');
            delete('MODIS_dates6.dat');
        else
            movefile([CurrentPath '/Output6/' 'MODIS_Filled.filled'],[CurrentPath '/Output6/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST6.dat');
            delete('MODIS_mask6.dat');
            delete('MODIS_dates6.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF6 = 0106;

end