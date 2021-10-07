function LST_DINEOF2 = dineof0102(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output2')
for Chunk = 217:432
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST2.dat',single(LST_Chunk));
    gwrite('MODIS_mask2.dat',single(mask_Chunk));
    gwrite('MODIS_dates2.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST2.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output2']);
        delete('MODIS_mask2.dat');
        delete('MODIS_dates2.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-2.0-x64-linux dineof2.init')
        
        if exist([CurrentPath '/Output2/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST2.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output2']);
            delete('MODIS_mask2.dat');
            delete('MODIS_dates2.dat');
        else
            movefile([CurrentPath '/Output2/' 'MODIS_Filled.filled'],[CurrentPath '/Output2/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST2.dat');
            delete('MODIS_mask2.dat');
            delete('MODIS_dates2.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF2 = 0102;

end