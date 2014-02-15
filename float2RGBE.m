function imgRGBE=float2RGBE(img)
    %
    %       imgRGBE=float2RGBE(img)
    %
    %
    %        Input:
    %           -img: a HDR image in RGB single float format
    %
    %        Output:
    %           -imgRGBE: the HDR image encoded using the RGBE format
    %

    [m,n,c]=size(img);
    imgRGBE=zeros(m,n,4);

    v=max(img,[],3);

    Low=find(v<1e-32);

    v2=v;
    [v,e] = log2(v);
    e=e+128;
    v=v*256./v2;
    v(Low)=0;
    e(Low)=0;

    for i=1:3
	imgRGBE(:,:,i)=round(img(:,:,i).*v);
    end

    imgRGBE(:,:,4)=e;

end