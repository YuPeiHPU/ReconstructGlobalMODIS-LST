function LST_DINEOF4 = dineof0204(Original_Path,LST_list,mask_list,dates,CurrentPath)

mkdir('Output4')
for Chunk = 640:852
    
    N = sprintf('%04d',Chunk);
    FileName1 = LST_list(Chunk,1).name;
    FileName2 = mask_list(Chunk,1).name;
    LST_Chunk = gread([Original_Path FileName1]);
    mask_Chunk = gread([Original_Path FileName2]);
    
    gwrite('MODIS_LST4.dat',single(LST_Chunk));
    gwrite('MODIS_mask4.dat',single(mask_Chunk));
    gwrite('MODIS_dates4.dat',single(dates));
    
    if mask_Chunk == 0
        movefile(sprintf('MODIS_LST4.dat'),sprintf('MODIS_Filled_%s.dat',N));
        movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output4']);
        delete('MODIS_mask4.dat');
        delete('MODIS_dates4.dat');
        continue
    else
        cd (CurrentPath);
        system('./dineof-4.0-x64-linux dineof4.init')
        
        if exist([CurrentPath '/Output4/' 'MODIS_Filled.filled'],'file') == 0
            movefile(sprintf('MODIS_LST4.dat'),sprintf('MODIS_Filled_%s.dat',N));
            movefile(sprintf('MODIS_Filled_%s.dat',N),[CurrentPath '/Output4']);
            delete('MODIS_mask4.dat');
            delete('MODIS_dates4.dat');
        else
            movefile([CurrentPath '/Output4/' 'MODIS_Filled.filled'],[CurrentPath '/Output4/' sprintf('MODIS_Filled_%s.filled',N)]);
            delete('MODIS_LST4.dat');
            delete('MODIS_mask4.dat');
            delete('MODIS_dates4.dat');
        end
        
        cd (CurrentPath);
        
    end
end

LST_DINEOF4 = 0104;

end