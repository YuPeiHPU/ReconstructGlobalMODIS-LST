function LST_DINEOF3 = dineof0203(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output3')
for Chunk = 427:639
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST3.dat',single(LST_Chunk));
    gwrite('MODIS_mask3.dat',single(mask_Chunk));
    gwrite('MODIS_dates3.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST3.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output3']);
        delete('MODIS_mask3.dat');
        delete('MODIS_dates3.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-3.0-x64-linux dineof3.init')
        
        if exist([CurrentPath '/Output3/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST3.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output3']);
            delete('MODIS_mask3.dat');
            delete('MODIS_dates3.dat');
        else
            movefile([CurrentPath '/Output3/' 'MODIS_Filled.filled'],[CurrentPath '/Output3/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST3.dat');
            delete('MODIS_mask3.dat');
            delete('MODIS_dates3.dat');
        end
        
        cd (CurrentPath);
        
    end
end


LST_DINEOF3 = 0103;

end