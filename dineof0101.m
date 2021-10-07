function LST_DINEOF1 = dineof0101(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output1')
for Chunk = 1:216
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST1.dat',single(LST_Chunk));
    gwrite('MODIS_mask1.dat',single(mask_Chunk));
    gwrite('MODIS_dates1.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST1.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output1']);
        delete('MODIS_mask1.dat');
        delete('MODIS_dates1.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-1.0-x64-linux dineof1.init')
        
        if exist([CurrentPath '/Output1/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST1.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output1']);
            delete('MODIS_mask1.dat');
            delete('MODIS_dates1.dat');
        else
            movefile([CurrentPath '/Output1/' 'MODIS_Filled.filled'],[CurrentPath '/Output1/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST1.dat');
            delete('MODIS_mask1.dat');
            delete('MODIS_dates1.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF1 = 0101;

end