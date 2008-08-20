function [S,par_type]=sgems_get_par(par_type);

S.null='';
par_dir=[mgstat_dir,filesep,'sgems',filesep,'def_par'];

if nargin==0;
    d=dir(par_dir);
    j=0;
    for i=1:length(d);
        if (d(i).isdir)
            if (~strcmp(d(i).name,'.')&(~strcmp(d(i).name,'..')))
                j=j+1;
                par_type{j}=d(i).name;
                mgstat_verbose(sprintf('%s : available SGeMS type %s ',mfilename,par_type{j}),10)
                %mgstat_verbose(sprintf('Available SGeMS type %s ',par_type{j}),10)
            end
        end
    end
    return
end

def_dir=[par_dir,filesep,par_type];
if exist(def_dir,'dir')~=7
    mgstat_verbose(sprintf('%s : Could not locate dir %s',mfilename,def_dir),10);
    sgems_get_par;
    return;
end





d=dir(def_dir);
for i=1:length(d);
    if (d(i).isdir==0)
        if isunix, 
            cmd='cp';;
        else
            cmd='copy';
        end
        cmd2=[cmd,' ',def_dir,filesep,d(i).name,' ',pwd,filesep,filesep,d(i).name];
        [status,result] = system(cmd2);
        if strfind(result,'1 fil')
            mgstat_verbose(sprintf('%s : %s',mfilename,result),1)
        else
            mgstat_verbose(sprintf('%s : COULD NOT COPY %s to %s',mfilename,d(i).name.pwd),10)
        end
    end
end
par_file=[par_type,'.par'];


% LOAD DEFAULT PAR FILE IF IT EXIST
if ~(exist(par_file,'file')==2)
    mgstat_verbose(sprintf('%s : Could not locate %s for %s-type SGeMS',mfilename,par_file,alg),10)
    return
end

% LOAD TI IF IT EXIST
ti_file=[par_type,'.ti'];
if (exist(ti_file,'file')==2)
    S.ti_file=ti_file;
end
S.xml_file=par_file;
S.XML=sgems_read_xml(par_file);


