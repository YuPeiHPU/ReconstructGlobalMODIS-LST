function LST_DINEOF12 = dineof0212(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output12')
for Chunk = 2486:2556
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST12.dat',single(LST_Chunk));
    gwrite('MODIS_mask12.dat',single(mask_Chunk));
    gwrite('MODIS_dates12.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST12.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output12']);
        delete('MODIS_mask12.dat');
        delete('MODIS_dates12.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-12.0-x64-linux dineof12.init')
        
        if exist([CurrentPath '/Output12/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST12.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output12']);
            delete('MODIS_mask12.dat');
            delete('MODIS_dates12.dat');
        else
            movefile([CurrentPath '/Output12/' 'MODIS_Filled.filled'],[CurrentPath '/Output12/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST12.dat');
            delete('MODIS_mask12.dat');
            delete('MODIS_dates12.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF12 = 0112;

end