function SaveFig(FigNumber, FigName)

% function SaveFig(FigNumber, FigName)
%
% Function that saves the figure number 'FigNumber' in % the various
%format that I standardly use:
% Matlab fig
% EPS
% JPEG (R=600)
% Illustrator

p='''';
disp('Saving format Matlab figure ...');

eval(['saveas(figure(',num2str(FigNumber),'),', ...
        p,FigName,p,',', ...
        p,'fig',p,');']);
%         set(gca,'FontSize',22);
%disp('Saving format EPS figure ...');
%eval(['print -depsc2 -adobecset -r600 ',FigName]); 

disp('Saving format JPEG figure ...');
set(gca,'FontSize',9);
set(get(gca,'xlabel'),'FontSize',11);
% % % set(get(gca,'ylabel'),'FontSize',15);
%set(get(gca,'Title'),'FontSize', 22);
eval(['print -djpeg -r600 ',FigName]);

%disp('Saving format Illustrator figure ...');
%eval(['print -dill ',FigName]);

