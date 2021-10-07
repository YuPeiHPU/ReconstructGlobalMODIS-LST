function LST_DINEOF9 = dineof0309(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output9')
for Chunk = 1729:2304
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST9.dat',single(LST_Chunk));
    gwrite('MODIS_mask9.dat',single(mask_Chunk));
    gwrite('MODIS_dates9.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST9.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output9']);
        delete('MODIS_mask9.dat');
        delete('MODIS_dates9.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-9.0-x64-linux dineof9.init')
        
        if exist([CurrentPath '/Output9/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST9.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output9']);
            delete('MODIS_mask9.dat');
            delete('MODIS_dates9.dat');
        else
            movefile([CurrentPath '/Output9/' 'MODIS_Filled.filled'],[CurrentPath '/Output9/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST9.dat');
            delete('MODIS_mask9.dat');
            delete('MODIS_dates9.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF9 = 0109;

end