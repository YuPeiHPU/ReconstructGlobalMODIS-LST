function LST_DINEOF8 = dineof0208(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output8')
for Chunk = 1492:1704
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST8.dat',single(LST_Chunk));
    gwrite('MODIS_mask8.dat',single(mask_Chunk));
    gwrite('MODIS_dates8.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST8.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output8']);
        delete('MODIS_mask8.dat');
        delete('MODIS_dates8.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-8.0-x64-linux dineof8.init')
        
        if exist([CurrentPath '/Output8/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST8.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output8']);
            delete('MODIS_mask8.dat');
            delete('MODIS_dates8.dat');
        else
            movefile([CurrentPath '/Output8/' 'MODIS_Filled.filled'],[CurrentPath '/Output8/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST8.dat');
            delete('MODIS_mask8.dat');
            delete('MODIS_dates8.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF8 = 0108;

end