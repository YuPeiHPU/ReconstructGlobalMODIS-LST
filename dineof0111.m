function LST_DINEOF11 = dineof0111(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output11')
for Chunk = 2449:2520
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST11.dat',single(LST_Chunk));
    gwrite('MODIS_mask11.dat',single(mask_Chunk));
    gwrite('MODIS_dates11.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST11.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output11']);
        delete('MODIS_mask11.dat');
        delete('MODIS_dates11.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-11.0-x64-linux dineof11.init')
        
        if exist([CurrentPath '/Output11/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST11.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output11']);
            delete('MODIS_mask11.dat');
            delete('MODIS_dates11.dat');
        else
            movefile([CurrentPath '/Output11/' 'MODIS_Filled.filled'],[CurrentPath '/Output11/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST11.dat');
            delete('MODIS_mask11.dat');
            delete('MODIS_dates11.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF11 = 0111;

end