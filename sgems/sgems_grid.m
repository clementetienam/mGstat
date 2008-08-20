function S=sgems_grid(S,obs);

if ~isfield(S,'dim'), S.dim.null=0;end
    
if isfield(S.dim,'x');
    S.dim.nx=length(S.dim.x);
    S.dim.x0=S.dim.x(1);
    S.dim.dx=S.dim.x(2)-S.dim.x(1);
    try
        S.dim.dx=S.dim.x(2)-S.dim.x(1);
    catch
        S.dim.dx=1;
    end
end
if isfield(S.dim,'y');
    S.dim.ny=length(S.dim.y);
    S.dim.y0=S.dim.y(1);
    S.dim.dy=S.dim.y(2)-S.dim.y(1);
    try
        S.dim.dy=S.dim.y(2)-S.dim.y(1);
    catch
        S.dim.dy=1;
    end
end
if isfield(S.dim,'z');
    S.dim.nz=length(S.dim.z);
    S.dim.z0=S.dim.z(1);
    try
        S.dim.dz=S.dim.z(2)-S.dim.z(1);
    catch
        S.dim.dz=1;
    end
end

if ~isfield(S.dim,'nx');S.dim.nx=30;end
if ~isfield(S.dim,'ny');S.dim.ny=30;end
if ~isfield(S.dim,'nz');S.dim.nz=1;end

if ~isfield(S.dim,'dx');S.dim.dx=1;end
if ~isfield(S.dim,'dy');S.dim.dy=1;end
if ~isfield(S.dim,'dz');S.dim.dz=1;end

if ~isfield(S.dim,'x0');S.dim.x0=0;end
if ~isfield(S.dim,'y0');S.dim.y0=0;end
if ~isfield(S.dim,'z0');S.dim.z0=0;end


% Generate default python script
[py_script,S,XML]=sgems_grid_py(S);

% delete output eas file



try
    % sgsim, dssim, LU_sim
    property_name=XML.parameters.Property_Name.value;
catch
    % snesim_std
    property_name=XML.parameters.Property_Name_Sim.value;
end
eas_out=sprintf('%s.out',property_name);


%eas_out=sprintf('%s.out',XML.parameters.Property_Name.value);
if exist([pwd,filesep,eas_out])
    delete([pwd,filesep,eas_out]);
end
eas_finished='finished';
if exist([pwd,filesep,eas_finished])
    delete([pwd,filesep,eas_finished]);
end

mgstat_verbose(sprintf('%s : Trying to run SGeMS using %s, output to %s',mfilename,py_script,eas_out),11);

sgems(py_script);

%eas_out=sprintf('%s.out',XML.parameters.Property_Name.value);


S.data=read_eas(eas_out);

S.x=[0:1:(S.dim.nx-1)]*S.dim.dx+S.dim.x0;
S.y=[0:1:(S.dim.ny-1)]*S.dim.dy+S.dim.y0;
S.z=[0:1:(S.dim.nz-1)]*S.dim.dz+S.dim.z0;

nsim=size(S.data,2);
D=zeros(S.dim.nx,S.dim.ny,S.dim.nz,nsim);
for i=1:nsim;
    S.D(:,:,:,i)=reshape(S.data(:,i),S.dim.nx,S.dim.ny,S.dim.nz);
end

if exist([pwd,filesep,eas_finished])
    mgstat_verbose(sprintf('%s : SGeMS ran successfully',mfilename),11);
else
    mgstat_verbose(sprintf('%s : SGeMS FAILED',mfilename),11);
end