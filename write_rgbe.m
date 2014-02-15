function ret=write_rgbe(img,filename)
    %
    %       ret = write_rgbe(img,filename)
    %
    %
    %        Input:
    %           -img: the image to write on the hard disk
    %           -filename: the name of the image to write
    %
    %        Output:
    %           -ret: a boolean value, it is set to 1 if the write succeed, 0 otherwise
    %

    ret=0;

    fid = fopen(filename,'w');
    [n,m,c]=size(img);

    fprintf(fid,'#?RADIANCE\n');
    fprintf(fid,'FORMAT=32-bit_rle_rgbe\n');
    fprintf(fid,'EXPOSURE= 1.0000000000000\n\n');
    fprintf(fid,'-Y %d +X %d\n',n,m);

    RGBEbuffer=float2RGBE(img);

    %apply a rotation
    for i=1:4
	RGBEbuffer(:,:,i)=fliplr(RGBEbuffer(:,:,i));   
	%RGBEbuffer(:,:,i)=imrotate(RGBEbuffer(:,:,i),90,'nearest');
    end
    RGBEbuffer=imrotate(RGBEbuffer,90,'nearest');

    %reshape of data
    data=zeros(n*m*4,1);

    for i=1:4
	C=i:4:(m*n*4);
	data(C)=reshape(RGBEbuffer(:,:,i),m*n,1);
    end

    fwrite(fid,data,'uint8');

    fclose(fid);

end