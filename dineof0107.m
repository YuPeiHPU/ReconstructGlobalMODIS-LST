function LST_DINEOF7 = dineof0107(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output7')
for Chunk = 1297:1512
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST7.dat',single(LST_Chunk));
    gwrite('MODIS_mask7.dat',single(mask_Chunk));
    gwrite('MODIS_dates7.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST7.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output7']);
        delete('MODIS_mask7.dat');
        delete('MODIS_dates7.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-7.0-x64-linux dineof7.init')
        
        if exist([CurrentPath '/Output7/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST7.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output7']);
            delete('MODIS_mask7.dat');
            delete('MODIS_dates7.dat');
        else
            movefile([CurrentPath '/Output7/' 'MODIS_Filled.filled'],[CurrentPath '/Output7/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST7.dat');
            delete('MODIS_mask7.dat');
            delete('MODIS_dates7.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF7 = 0107;

end