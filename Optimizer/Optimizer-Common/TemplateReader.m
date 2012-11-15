function AEtemplate = TemplateReader(fid)
%TEMPLATEREADER Reader of a template file
%   ONLY CRFpp-sytle template files are supported!
%   input:  fid
%   output: AEtemplate
%
%   lastest mod: feb 26, 2011; 13:32

%% main
FeatNum = 0;

while ~feof(fid)
    tLine = fgetl(fid);
    
    % skip comments #..., empty lines and empty features
    if length(tLine)>1&&~strcmp(tLine(1),'#')
        FeatNum = FeatNum + 1;
        
        % extract feature type and id
        AEtemplate(FeatNum).featType = tLine(1);
        AEtemplate(FeatNum).featId = sscanf(tLine,'%*c%d:%*s');
        
        % trunc the string with character '/'
        xSet = strread(tLine(findstr(tLine,':')+1:end),'%s','delimiter','/');
        
        % read data from each
        AEtemplate(FeatNum).featExp = cell(0);
        for i_xSet = 1:length(xSet)
            AEtemplate(FeatNum).featExp = [AEtemplate(FeatNum).featExp, sscanf(xSet{i_xSet},'%%x[%d,%d]')'];
        end
    end
end

end

