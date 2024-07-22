 
%% 模型参数
clear
clc
close all
filename = 'demo';
num = 1;
file = sprintf("%s.%s",filename,'txt');
% 生成加工信息info、基础信息Global
[info,Global] = info_Global(file);
%% 遗传算法参数
maxgen = 200;             %进化代数
sizepop = 100;            %种群规模
%% 个体初始化
%种群结构体
individuals=struct('fitness',zeros(1,sizepop), 'chrom',[],'chrom_CS',[],'chrom_WS',[]);

% 初始化种群
for i=1:sizepop
    if (i<=0.1*sizepop) 
        %随机产生个体
        [individuals.chrom(i,:),individuals.chrom_CS(i,:),individuals.chrom_WS(i,:)]= Code_RS(Global,info);
    end
    if (i>0.1*sizepop && i<=0.8*sizepop)
        %全局选择产生个体
        [individuals.chrom(i,:),individuals.chrom_CS(i,:),individuals.chrom_WS(i,:)] = Code_GS(Global,info);       
    end
    if (i>0.8*sizepop)
        %局部选择产生个体
        [individuals.chrom(i,:),individuals.chrom_CS(i,:),individuals.chrom_WS(i,:)]=Code_LS(Global,info);       
    end
    x(1,:)=individuals.chrom_CS(i,:);
    x(2,:)=individuals.chrom_WS(i,:);
    x(3,:)=individuals.chrom(i,:);
    individuals.fitness(i)=Global.fun(x);       %个体适应度
end
%找最好的染色体
[bestfitness,bestindex] = min(individuals.fitness);
%最好的染色体
bestchrom(1,:) = individuals.chrom_CS(bestindex,:);
bestchrom(2,:) = individuals.chrom_WS(bestindex,:);
bestchrom(3,:) = individuals.chrom(bestindex,:);  

figure(1)
hold off
plot(1,1)
Draw_Gantt(bestchrom,Global,info)
set(gcf , 'position' , [50 200 900 400])

avgfitness=sum(individuals.fitness)/sizepop; %染色体的平均适应度
% 记录每一代进化中最好的适应度和平均适应度
trace=[];
best_chrom = [];
best_fitness = [];
tic