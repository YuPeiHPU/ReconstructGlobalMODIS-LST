function LST_DINEOF5 = dineof0205(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output5')
for Chunk = 853:1065
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST5.dat',single(LST_Chunk));
    gwrite('MODIS_mask5.dat',single(mask_Chunk));
    gwrite('MODIS_dates5.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST5.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output5']);
        delete('MODIS_mask5.dat');
        delete('MODIS_dates5.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-5.0-x64-linux dineof5.init')
        
        if exist([CurrentPath '/Output5/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST5.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output5']);
            delete('MODIS_mask5.dat');
            delete('MODIS_dates5.dat');
        else
            movefile([CurrentPath '/Output5/' 'MODIS_Filled.filled'],[CurrentPath '/Output5/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST5.dat');
            delete('MODIS_mask5.dat');
            delete('MODIS_dates5.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF5 = 0105;

end