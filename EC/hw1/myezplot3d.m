function myezplot3d(plotfunhandle,funhandle,lb,ub)
[X,Y]=meshgrid(linspace(lb,ub,60),linspace(lb,ub,60));
Z=feval(funhandle,([X(:) Y(:)]));
Z3=reshape(Z,size(X));
plotfunhandle(X,Y,Z3);
shading interp
colorbar
figure(gcf);