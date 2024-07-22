% 初始化info（两个工件信息的结构体）以及基础数据Global
function [info,Global]=info_Global(x)
%构建工件信息数据结构
empty.num_gongxu=[];
empty.gongxu=[];

empty_gongxu.num_jichuang=[];
empty_gongxu.data=[];
empty_gongxu.bianhao=[];

% 存储装夹区不同工位的操作时间
empty_gongxu.num_Clamping = [];
empty_gongxu.data_C = [];
empty_gongxu.bianhao_C = [];
% 存储待加工区不同工位的操作时间
empty_gongxu.num_Waiting = [];
empty_gongxu.data_W = [];
empty_gongxu.bianhao_W = [];
% 存储加工区不同机器的操作时间
empty_gongxu.num_Machine = [];
empty_gongxu.data_M = [];
empty_gongxu.bianhao_M = [];

mk = dlmread(x);%textscan
I = mk(1,1);
M = mk(1,2);

C = mk(1,4);    %工件信息txt文件中,第一行第四个数字表示装夹区工位数量
W = mk(1,5);

%repmat重复数组副本，构建1X5结构体
% info = repmat(empty,1,Global.I);  %工件加工能耗/时间信息表
info = repmat(empty,1,I);           %工件加工能耗/时间信息表
num_gongxu_max = 0;     %记录当前任务中，所有工件中最大的工序数量
for i = 1:I    
    info(i).num_gongxu = mk(i+1,1);     %当前工件的工序总数
    if mk(i+1,1) > num_gongxu_max   
        num_gongxu_max = mk(i+1,1); %更新最大工序数量
    end
    info(i).gongxu = repmat(empty_gongxu,1,info(i).num_gongxu);

    k = 2;    
    for j = 1:info(i).num_gongxu
        info(i).gongxu(j).num_jichuang = mk(i+1,k);         %读取工件每一工序的可用机床数量
        n = k+1;
        % 读取每一工序可用机床编号和加工时间
        for m = 1:mk(i+1,k)
            info(i).gongxu(j).bianhao = [info(i).gongxu(j).bianhao mk(i+1,n)];
            %data数据依次为：工序加工能耗	工序加工时间	对刀时间
            info(i).gongxu(j).data=[info(i).gongxu(j).data;0 mk(i+1,n+1) 0];
            n = n+2;
        end
        k = k + 2 * mk(i+1,k) + 1;
    end

    
    % 读取每一工序可用加工机器数量、编号、操作时间
    k = 2;
    line = i+1;     %当前数据起始行数
    for j = 1:info(i).num_gongxu

        % info(i).gongxu(j).num_Clamping = C;
        % info(i).gongxu(j).num_Waiting = W;
        % 
        % info(i).gongxu(j).bianhao_C = 1:C;
        % info(i).gongxu(j).bianhao_W = 1:W;
        % 
        % info(i).gongxu(j).data_C = 2*ones(1,C);
        % info(i).gongxu(j).data_W = 3*ones(1,W);

        info(i).gongxu(j).num_Machine = mk(line,k);     %读取工件每一工序的可用装夹区工位数量
        n = k+1;
        % 读取每一工序可用装夹区工位编号和操作时间
        for m=1:mk(line,k)
            info(i).gongxu(j).bianhao_M = [info(i).gongxu(j).bianhao_M mk(line,n)];
            info(i).gongxu(j).data_M = [info(i).gongxu(j).data_M mk(line,n+1)];
            n = n+2;
        end
        k = k + 2 * mk(line,k) + 1;
    end

    % 读取每一工序可用装夹区工位数量、编号、操作时间
    k = 2;
    line = i+1+I+1;     %当前数据起始行数
    for j = 1:info(i).num_gongxu
        info(i).gongxu(j).num_Clamping = mk(line,k);     %读取工件每一工序的可用装夹区工位数量
        n = k+1;
        % 读取每一工序可用装夹区工位编号和操作时间
        for m=1:mk(line,k)
            info(i).gongxu(j).bianhao_C = [info(i).gongxu(j).bianhao_C mk(line,n)];
            info(i).gongxu(j).data_C = [info(i).gongxu(j).data_C mk(line,n+1)];
            n = n+2;
        end
        k = k + 2 * mk(line,k) + 1;
    end

    % 读取每一工序可用待加工区工位数量、编号、操作时间
    k = 2;
    line = i+1+2*(I+1);     %当前数据起始行数
    for j = 1:info(i).num_gongxu
        info(i).gongxu(j).num_Waiting = mk(line,k);     %读取工件每一工序的可用装夹区工位数量
        n = k+1;
        % 读取每一工序可用装夹区工位编号和操作时间
        for m=1:mk(line,k)
            info(i).gongxu(j).bianhao_W = [info(i).gongxu(j).bianhao_W mk(line,n)];
            info(i).gongxu(j).data_W = [info(i).gongxu(j).data_W mk(line,n+1)];
            n = n+2;
        end
        k = k + 2 * mk(line,k) + 1;
    end

end

%生成基础数据
Ai = zeros(1,I);%工件到达时间Ai
Di = ones(1,I).*60;%交货期Di
M_power = zeros(M,2);%机床功率M_power
Ni = ones(1,I);%每种工件的加工数量Ni

Global.C = C;   %装夹区工位数量
Global.W = W;   %待加工区工位数量

Global.M = M;%可用机床数量
Global.I = I;%工件种类数
Global.Max_operations = num_gongxu_max;%工序数量最大值
Global.m_power = M_power;
Global.Ni = Ni;%加工数量都为1
Global.Ai = Ai;%到达时间都为0
Global.Di = Di;
Global.xishu=[1,0];
% Global.fun = @(x) fun_gai(x);%改成fun1就是有故障的。
% Global.fun = @(x) fun_gai(x,Global,info);%改成fun1就是有故障的。
Global.fun = @(x) fun_cwp(x,Global,info);
end


%% CWPFJSP_TM模型的目标函数，计算适应度值，
% 输入为工序排序、装夹工位选择、待加工工位选择、机器选择数组
function [y,release_time,used_device,T_start,T_need,T_end,T_total,T_jiagong,T_kongxian] = fun_cwp(x,Global,info)

nVar = numel(x(1,:));
% 从头到尾安排工件进行加工

T_jiagong = 0;                      %加工时间
T_kongxian = 0;                     %空闲时间

%CS表示工件在装夹区工位进行的操作
T_startC = zeros(Global.I,Global.Max_operations);       %CS开工时间
T_needC = zeros(Global.I,Global.Max_operations);        %CS所需工作时间
T_endC = zeros(Global.I,Global.Max_operations);         %CS完工时间

%WS表示工件在待加工区工位进行的操作
T_startW = zeros(Global.I,Global.Max_operations);       %WS开工时间
T_needW = zeros(Global.I,Global.Max_operations);        %WS所需工作时间
T_endW = zeros(Global.I,Global.Max_operations);         %WS完工时间

%MS表示工件在机器上进行的操作
T_startM = zeros(Global.I,Global.Max_operations);        %MS开工时间
T_needM = zeros(Global.I,Global.Max_operations);         %MS所需加工时间
T_endM = zeros(Global.I,Global.Max_operations);          %MS完工时间

release_timeC = zeros(1,Global.C);  %各装夹区工位下一次的可用时间
release_timeW = zeros(1,Global.W);  %各待加工区工位下一次的可用时间
release_timeM = zeros(1,Global.M);   %各机器下一次的可用时间

count_gongxu = ones(1,Global.I);        %记录所有工件的当前工序

count_clamping = zeros(1,Global.C);     %记录各装夹区工位使用次数
count_waiting = zeros(1,Global.W);      %记录各待加工区工位使用次数
count_machine = zeros(1,Global.M);      %记录各机器使用次数

use_clamping(Global.I,Global.Max_operations) = 0;        %记录每一工件的每一工序使用的装夹区工位，直接赋值,预分配内存
use_waiting(Global.I,Global.Max_operations) = 0;         %记录每一工件的每一工序使用的待加工区工位
use_machine(Global.I,Global.Max_operations) = 0;         %记录每一工件的每一工序使用的机器

for i=1:nVar/2
    cur_gongjian = x(3,i);                                                          %获取当前工件号
    cur_gongxu = count_gongxu(cur_gongjian);                                        %读取当前工件此时的工序号

    cur_clamping = x(1,nVar/2+i);                                                   %获取为当前工序安排的装夹区工位顺序号
    cur_waiting = x(2,nVar/2+i);                                                    %获取为当前工序安排的待加工区区工位顺序号
    cur_machine = x(3,nVar/2+i);                                                    %获取为当前工序安排的机器顺序号

    cur_clamping_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao_C(cur_clamping);  %获取当前工序的装夹区工位编号
    cur_waiting_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao_W(cur_waiting);    %获取当前工序的待加工区工位编号
    cur_machine_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao_M(cur_machine);    %获取当前工序的机器编号
    
    use_clamping(cur_gongjian,cur_gongxu) = cur_clamping_code;  %记录当前工件当前工序的装夹区工位
    use_waiting(cur_gongjian,cur_gongxu) = cur_waiting_code;    %记录当前工件当前工序的待加工区工位
    use_machine(cur_gongjian,cur_gongxu) = cur_machine_code;    %记录当前工件当前工序的加工机器
    
    count_clamping(cur_clamping_code) = count_clamping(cur_clamping_code) + 1;  %将当前装夹区工位的使用次数+1
    count_waiting(cur_waiting_code) = count_waiting(cur_waiting_code) + 1;      %将当前待加工区工位的使用次数+1
    count_machine(cur_machine_code) = count_machine(cur_machine_code) + 1;      %将当前机器的使用次数+1
    
    %判断当前工序是否为该工件的首个工序
    if cur_gongxu == 1 %为当前工件的首个工序
        %判断CA是否被占用
        if release_timeC(cur_clamping_code) > Global.Ai(cur_gongjian) % 当前CA被占用。Ai为工件到达时间
            %更新装夹区操作
            T_startC(cur_gongjian,cur_gongxu) = release_timeC(cur_clamping_code);
            T_needC(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_C(cur_clamping);
            release_timeC(cur_clamping_code) = release_timeC(cur_clamping_code) + T_needC(cur_gongjian,cur_gongxu);
            %统计CA操作时间
            T_jiagong = T_jiagong + T_needC(cur_gongjian,cur_gongxu);
            T_endC(cur_gongjian,cur_gongxu) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);

            %判断WA是否被占用
            if release_timeW(cur_waiting_code) > T_endC(cur_gongjian,cur_gongxu) %当前WA被占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = release_timeW(cur_waiting_code);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                release_timeW(cur_waiting_code) = release_timeW(cur_waiting_code) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            else %--------------------------------------------------------------%当前WA未占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = T_endC(cur_gongjian,cur_gongxu);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                %统计WA空闲时间
                T_kongxian = T_kongxian + (T_startW(cur_gongjian,cur_gongxu) - release_timeW(cur_waiting_code));
                release_timeW(cur_waiting_code) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %---------------------------------------------------------------当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            end
        else %-------------------------------------------------------------------%当前CA未占用
            %更新装夹区操作
            T_startC(cur_gongjian,cur_gongxu) = Global.Ai(cur_gongjian);
            T_needC(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_C(cur_clamping);
            %统计CA空闲时间
            T_kongxian = T_kongxian + (T_startC(cur_gongjian,cur_gongxu) - release_timeC(cur_clamping_code));
            release_timeC(cur_clamping_code) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);
            %统计CA操作时间
            T_jiagong = T_jiagong + T_needC(cur_gongjian,cur_gongxu);
            T_endC(cur_gongjian,cur_gongxu) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);

            %判断WA是否被占用
            if release_timeW(cur_waiting_code) > T_endC(cur_gongjian,cur_gongxu) %当前WA被占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = release_timeW(cur_waiting_code);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                release_timeW(cur_waiting_code) = release_timeW(cur_waiting_code) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            else %--------------------------------------------------------------%当前WA未占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = T_endC(cur_gongjian,cur_gongxu);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                %统计WA空闲时间
                T_kongxian = T_kongxian + (T_startW(cur_gongjian,cur_gongxu) - release_timeW(cur_waiting_code));
                release_timeW(cur_waiting_code) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            end
        end

    else %-------------%非当前工件的首个工序
        %判断CA是否被占用
        if release_timeC(cur_clamping_code) > T_endM(cur_gongjian,cur_gongxu-1) %当前CA被占用。当前工件上一工序机器完工时间早，提前到达
            %更新装夹区操作
            T_startC(cur_gongjian,cur_gongxu) = release_timeC(cur_clamping_code);
            T_needC(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_C(cur_clamping);
            release_timeC(cur_clamping_code) = release_timeC(cur_clamping_code) + T_needC(cur_gongjian,cur_gongxu);
            %统计CA操作时间
            T_jiagong = T_jiagong + T_needC(cur_gongjian,cur_gongxu);
            T_endC(cur_gongjian,cur_gongxu) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);

            %判断WA是否被占用
            if release_timeW(cur_waiting_code) > T_endC(cur_gongjian,cur_gongxu) %当前WA被占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = release_timeW(cur_waiting_code);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                release_timeW(cur_waiting_code) = release_timeW(cur_waiting_code) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            else %--------------------------------------------------------------%当前WA未占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = T_endC(cur_gongjian,cur_gongxu);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                %统计WA空闲时间
                T_kongxian = T_kongxian + (T_startW(cur_gongjian,cur_gongxu) - release_timeW(cur_waiting_code));
                release_timeW(cur_waiting_code) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %---------------------------------------------------------------当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            end
        else %----------------------------------------------------------------%当前CA未占用
            %更新装夹区操作
            T_startC(cur_gongjian,cur_gongxu) = T_endM(cur_gongjian,cur_gongxu-1);
            T_needC(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_C(cur_clamping);
            %统计CA空闲时间
            T_kongxian = T_kongxian + (T_startC(cur_gongjian,cur_gongxu) - release_timeC(cur_clamping_code));
            release_timeC(cur_clamping_code) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);
            %统计CA操作时间
            T_jiagong = T_jiagong + T_needC(cur_gongjian,cur_gongxu);
            T_endC(cur_gongjian,cur_gongxu) = T_startC(cur_gongjian,cur_gongxu) + T_needC(cur_gongjian,cur_gongxu);

            %判断WA是否被占用
            if release_timeW(cur_waiting_code) > T_endC(cur_gongjian,cur_gongxu) %当前WA被占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = release_timeW(cur_waiting_code);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                release_timeW(cur_waiting_code) = release_timeW(cur_waiting_code) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            else %--------------------------------------------------------------%当前WA未占用
                %更新待加工区操作
                T_startW(cur_gongjian,cur_gongxu) = T_endC(cur_gongjian,cur_gongxu);
                T_needW(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_W(cur_waiting);
                %统计WA空闲时间
                T_kongxian = T_kongxian + (T_startW(cur_gongjian,cur_gongxu) - release_timeW(cur_waiting_code));
                release_timeW(cur_waiting_code) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);
                %统计WA操作时间
                T_jiagong = T_jiagong + T_needW(cur_gongjian,cur_gongxu);
                T_endW(cur_gongjian,cur_gongxu) = T_startW(cur_gongjian,cur_gongxu) + T_needW(cur_gongjian,cur_gongxu);

                %判断机器是否被占用
                if release_timeM(cur_machine_code) > T_endW(cur_gongjian,cur_gongxu) %当前机器被占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = release_timeM(cur_machine_code);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    release_timeM(cur_machine_code) = release_timeM(cur_machine_code) + T_needM(cur_gongjian,cur_gongxu);
                else %--------------------------------------------------------------%当前机器未占用
                    %更新加工区操作
                    T_startM(cur_gongjian,cur_gongxu) = T_endW(cur_gongjian,cur_gongxu);
                    T_needM(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data_M(cur_machine);
                    %统计机器空闲时间
                    T_kongxian = T_kongxian + (T_startM(cur_gongjian,cur_gongxu) - release_timeM(cur_machine_code));
                    release_timeM(cur_machine_code) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
                end
                %统计机器加工时间
                T_jiagong = T_jiagong + T_needM(cur_gongjian,cur_gongxu);
                T_endM(cur_gongjian,cur_gongxu) = T_startM(cur_gongjian,cur_gongxu) + T_needM(cur_gongjian,cur_gongxu);
            end
        end

    end
    
    %指向当前工件的下一工序，记录当前工件的工序号+1
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian) + 1;

end

release_time = struct("C",release_timeC,"W",release_timeW,"M",release_timeM);
used_device = struct("C",use_clamping,"W",use_waiting,"M",use_machine);

T_start = struct("C",T_startC,"W",T_startW,"M",T_startM);
T_need = struct("C",T_needC,"W",T_needW,"M",T_needM);
T_end = struct("C",T_endC,"W",T_endW,"M",T_endM);

non_use = Global.M - numel(find(count_machine));
T_total = max(release_timeM);

xishu = Global.xishu;
y = sum([1*T_total 0].*xishu) + non_use*(0);
end

%% 目标函数，计算适应度值，输入为工序排序与机器选择数组
function [y,release_time,use_machine,T_start,T_need,T_end,...
    T_total,T_jiagong,T_kongxian] = fun_gai(x,Global,info)

nVar = numel(x(1,:));
% 从头到尾安排工件进行加工

T_jiagong = 0;                      %加工时间
T_kongxian = 0;                     %空闲时间
T_start = zeros(Global.I,6);        %开工时间
T_need = zeros(Global.I,6);         %所需加工时间
T_end = zeros(Global.I,6);          %完工时间
release_time = zeros(1,Global.M);   %下一次的可用时间

count_gongxu=ones(1,Global.I);
count_gongjian=zeros(1,Global.M);   %记录机器使用次数
use_machine(1000,1000) = 0;         %直接赋值,预分配内存
for i=1:nVar/2
    cur_gongjian = x(3,i);                                                          %获取当前工件号
    cur_gongxu = count_gongxu(cur_gongjian);                                        %读取当前工件此时的工序号
    cur_machine = x(3,nVar/2+i);                                                    %获取为当前工序安排的机器顺序号    
    cur_machine_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao(cur_machine);  %获取当前工序的机器编号
    
    % 记录当前工件当前工序的加工机器
    use_machine(cur_gongjian,cur_gongxu) = cur_machine_code;
    
    %将当前使用机器的使用次数+1
    count_gongjian(cur_machine_code) = count_gongjian(cur_machine_code) + 1;
    
    if cur_gongxu==1 %当前工件的首个工序
        if release_time(cur_machine_code)>Global.Ai(cur_gongjian) %当前机床被占用
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = Global.Ai(cur_gongjian);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);          

            T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
        T_jiagong = T_jiagong+T_need(cur_gongjian,cur_gongxu);
        
        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        
    else %不是首个工序
        if release_time(cur_machine_code)>T_end(cur_gongjian,cur_gongxu-1) %当前机床被占用
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = T_end(cur_gongjian,cur_gongxu-1);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            
            T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
        T_jiagong = T_jiagong+T_need(cur_gongjian,cur_gongxu);

        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
    end
    
    %将当前工件此时的工序号+1，指向下一工序
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
end
non_use = Global.M - numel(find(count_gongjian));
T_total = max(release_time);

xishu = Global.xishu;
y = sum([1*T_total 0].*xishu) + non_use*(0);
end

%% 借助Global/info进行全局选择
function [ret,CS,WS]=Code_GS(Global,info)
all_gongxu=[];
for i=1:Global.I
    %按照工件顺序产生所有工序合集，共I个工件，可得工序总数all_gongxu。
    %数组值代表工件号，相同工件的出现次序表示该工件的工序顺序
    y=info(i).num_gongxu;
    all_gongxu_1=[all_gongxu i.*ones(1,y)];
    all_gongxu = all_gongxu_1;
end
%产生1~all_gongxu的随机工序索引序列
index=randperm(numel(all_gongxu));%numel返回数组元素数目
%用随机序列索引工序合集，获得随机的工序排序
ret1 = all_gongxu(index);

%根据生成的工序安排机器、装夹区工位、待加工区工位
machine = [];
clamping = [];
waiting = [];

%按工件数构建数组，数组下标对应工件，数组值代表相应工件的当前工序号
cur_gongxu = ones(1,Global.I);

%记录全局机器、装夹区工位、待加工区工位使用时间
machine_time = zeros(1,Global.M); 
clamping_time = zeros(1,Global.C);
waiting_time = zeros(1,Global.W);

% for j=1:numel(ret1)
%     %获取当前工件号
%     cur_gongjian=ret1(j);
%     %获取可选机床的编号
%     cur_bianhao = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).bianhao;
%     %获取相应机床的加工时间
%     cur_time = [];
%     for k=1:numel(cur_bianhao)
%         cur_time_1 = [cur_time info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).data(k,2)];
%         cur_time = cur_time_1;
%     end
% 
%     cur_sum_time = machine_time(cur_bianhao)+cur_time;  %计算可选机床当前被使用的总时间
%     [cur_best_time,cur_best_index]=min(cur_sum_time);   %寻找总使用时间最小的机床
% 
%     %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
%     machine_1=[machine cur_best_index];
%     machine = machine_1;
% 
%     machine_time(cur_bianhao(cur_best_index)) = cur_best_time;
% 
%     %指向当前工件的下一个工序
%     cur_gongxu(cur_gongjian) = cur_gongxu(cur_gongjian)+1;
% end
for j=1:numel(ret1)
    %获取当前工件号
    cur_gongjian=ret1(j);
    %获取可选机器、装夹区工位、待加工区工位的编号
    cur_bianhao_M = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).bianhao_M;
    cur_bianhao_C = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).bianhao_C;
    cur_bianhao_W = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).bianhao_W;
    %获取相应的操作时间
    cur_time_M = [];
    cur_time_C = [];
    cur_time_W = [];

    for k=1:numel(cur_bianhao_M)
        cur_time_1 = [cur_time_M info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).data_M(k)];
        cur_time_M = cur_time_1;
    end
    for k=1:numel(cur_bianhao_C)
        cur_time_2 = [cur_time_C info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).data_C(k)];
        cur_time_C = cur_time_2;
    end
    for k=1:numel(cur_bianhao_W)
        cur_time_3 = [cur_time_W info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).data_W(k)];
        cur_time_W = cur_time_3;
    end
    
    curSumTimeM = machine_time(cur_bianhao_M)+cur_time_M;   %计算可选机床当前被使用的总时间
    [curBestTimeM,cur_best_index]=min(curSumTimeM);         %寻找总使用时间最小的机床    
    %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
    machine_1=[machine cur_best_index];
    machine = machine_1;    
    machine_time(cur_bianhao_M(cur_best_index)) = curBestTimeM;

    curSumTimeC = clamping_time(cur_bianhao_C)+cur_time_C;      %计算可选机床当前被使用的总时间
    [curBestTimeC,cur_best_index]=min(curSumTimeC);             %寻找总使用时间最小的机床    
    %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
    clamping_1=[clamping cur_best_index];
    clamping = clamping_1;    
    clamping_time(cur_bianhao_C(cur_best_index)) = curBestTimeC;

    curSumTimeW = waiting_time(cur_bianhao_W)+cur_time_W;       %计算可选机床当前被使用的总时间
    [curBestTimeW,cur_best_index]=min(curSumTimeW);             %寻找总使用时间最小的机床    
    %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
    waiting_1=[waiting cur_best_index];
    waiting = waiting_1;    
    waiting_time(cur_bianhao_W(cur_best_index)) = curBestTimeW;
    
    %指向当前工件的下一个工序
    cur_gongxu(cur_gongjian) = cur_gongxu(cur_gongjian)+1;
end
%将随机生成的<工序顺序>与安排的<对应工序的加工机器>组合
ret = [ret1 machine];
CS = [ret1 clamping];
WS = [ret1 waiting];
end

% 借助Global/info局部选择
function [ret,CS,WS]=Code_LS(Global,info)
all_gongxu=[];
for i=1:Global.I
    %按照工件顺序产生所有工序合集，共I个工件，可得工序总数all_gongxu。
    %数组值代表工件号，相同工件的出现次序表示该工件的工序顺序
    y=info(i).num_gongxu;
    all_gongxu_1=[all_gongxu i.*ones(1,y)];
    all_gongxu = all_gongxu_1;
end
%产生1~all_gongxu的随机工序索引序列
index=randperm(numel(all_gongxu));%numel返回数组元素数目
%用随机序列索引工序合集，获得随机的工序排序
ret1 = all_gongxu(index);

%根据安排的工序安排机器
machine = zeros(1,numel(all_gongxu));
clamping = zeros(1,numel(all_gongxu));
waiting = zeros(1,numel(all_gongxu));

for j=1:Global.I
   machine_time = zeros(1,Global.M);    %记录每个工件的工序集机器使用时间
   clamping_time = zeros(1,Global.C);    %记录每个工件的工序集装夹区工位使用时间
   waiting_time = zeros(1,Global.W);     %记录每个工件的工序集待加工区工位使用时间

   %获取当前工件工序集合   
   cur_gongjian_jihe = find(ret1==j);

   %按当前工件的工序集合依次安排机器
   for k=1:numel(cur_gongjian_jihe)       
       %获取可选机器、装夹区工位、待加工区工位的编号
       cur_bianhao_M = info(j).gongxu(k).bianhao_M;
       cur_bianhao_C = info(j).gongxu(k).bianhao_C;
       cur_bianhao_W = info(j).gongxu(k).bianhao_W;

       %获取相应的操作时间
       cur_time_M = [];
       cur_time_C = [];
       cur_time_W = [];      

       for m=1:numel(cur_bianhao_M)
           cur_time_1 = [cur_time_M info(j).gongxu(k).data_M(m)];   
           cur_time_M = cur_time_1;
       end
       for m=1:numel(cur_bianhao_C)
           cur_time_2 = [cur_time_C info(j).gongxu(k).data_C(m)];   
           cur_time_C = cur_time_2;
       end
       for m=1:numel(cur_bianhao_W)
           cur_time_3 = [cur_time_W info(j).gongxu(k).data_W(m)];   
           cur_time_W = cur_time_3;
       end

       curSumTimeM = machine_time(cur_bianhao_M)+cur_time_M;%计算可选机床当前被使用的总时间
       [curBestTimeM,cur_best_index]=min(curSumTimeM);%寻找总使用时间最小的机床
       %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
       machine(cur_gongjian_jihe(k)) = cur_best_index;
       machine_time(cur_bianhao_M(cur_best_index)) = curBestTimeM;       

       curSumTimeC = clamping_time(cur_bianhao_C)+cur_time_C;%计算可选机床当前被使用的总时间
       [curBestTimeC,cur_best_index]=min(curSumTimeC);%寻找总使用时间最小的机床
       %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
       clamping(cur_gongjian_jihe(k)) = cur_best_index;
       clamping_time(cur_bianhao_C(cur_best_index)) = curBestTimeC;

       curSumTimeW = waiting_time(cur_bianhao_W)+cur_time_W;%计算可选机床当前被使用的总时间
       [curBestTimeW,cur_best_index]=min(curSumTimeW);%寻找总使用时间最小的机床
       %取总使用时间最小的机床为：当前加工机床的顺序号（小于可选加工机床数量）
       waiting(cur_gongjian_jihe(k)) = cur_best_index;
       waiting_time(cur_bianhao_W(cur_best_index)) = curBestTimeW;
   end

end
%将随机生成的<工序顺序>与安排的<对应工序的加工机器>组合
ret = [ret1 machine];
CS = [ret1 clamping];
WS = [ret1 waiting];
end

% 借助Global/info随机选择
function [ret,CS,WS]=Code_RS(Global,info)
all_gongxu=[];
for i=1:Global.I
    %按照工件顺序产生所有工序合集，共I个工件，可得工序总数all_gongxu。
    %数组值代表工件号，相同工件的出现次序表示该工件的工序顺序
    y=info(i).num_gongxu;
    all_gongxu_1=[all_gongxu i.*ones(1,y)];
    all_gongxu = all_gongxu_1;
end
%产生1~all_gongxu的随机工序索引序列
index=randperm(numel(all_gongxu));%numel返回数组元素数目
%用随机序列索引工序合集，获得随机的工序排序
ret1 = all_gongxu(index);

%根据生成的工序安排机器、装夹区工位、待加工区工位
machine = [];
clamping = [];
waiting = [];
%按工件数构建数组，数组下标对应工件，数组值代表相应工件的当前工序号
cur_gongxu = ones(1,Global.I);

% for j=1:numel(ret1)
%    %获取当前工件号
%    cur_gongjian=ret1(j);
%    %获取当前工件的->当前工序的->可选加工机床数量
%    num_machine = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).num_jichuang;
%    %按<可选加工机床数量>随机生成一个加工机床的顺序号（小于该数量）
%    machine_1=[machine randperm(num_machine,1)];
%    machine = machine_1;
%    %指向当前工件的下一个工序
%    cur_gongxu(cur_gongjian) = cur_gongxu(cur_gongjian)+1;
% end
for j=1:numel(ret1)
    %获取当前工件号
    cur_gongjian=ret1(j);
    %获取可选机器、装夹区工位、待加工区工位的数量
    num_M = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).num_Machine;
    num_C = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).num_Clamping;
    num_W = info(ret1(j)).gongxu(cur_gongxu(cur_gongjian)).num_Waiting;
    
    machine_1=[machine randperm(num_M,1)];
    machine = machine_1;    

    clamping_1=[clamping randperm(num_C,1)];
    clamping = clamping_1;    

    waiting_1=[waiting randperm(num_W,1)];
    waiting = waiting_1;    

    %指向当前工件的下一个工序
    cur_gongxu(cur_gongjian) = cur_gongxu(cur_gongjian)+1;
end

%将随机生成的<工序顺序>与安排的<对应工序的加工机器>组合
ret = [ret1 machine];
CS = [ret1 clamping];
WS = [ret1 waiting];
end

% 本函数对每一代种群中的染色体进行锦标赛选择
function ret=Select_tournament(individuals,sizepop)
index=[];
for i=1:sizepop
    pick = randperm(sizepop,2);%从种群中随机选择2个个体
    pick_fitness = individuals.fitness(pick);%记录适应度值
    [~,best_index] = min(pick_fitness);%寻找最小适应度个体
    index_1 = [index pick(best_index)];%选择最小适应度个体作为子代
    index = index_1;
end
individuals.chrom=individuals.chrom(index,:);
individuals.chrom_CS=individuals.chrom_CS(index,:);
individuals.chrom_WS=individuals.chrom_WS(index,:);

individuals.fitness=individuals.fitness(index);
ret=individuals;
end

% 基于关键工序的交叉
function ret = Cross_key(individuals,sizepop,Global,info)
n_Var = size(individuals.chrom,2)/2;
cur_prob = ceil(0.3*sizepop); %交叉概率
rand_chrom = randperm(sizepop,cur_prob);%随机产生交叉池
for h=1:cur_prob
    % 获取一个个体
    index = rand_chrom(h);
    P_chrom = individuals.chrom(index,:);
    
    [key_path,order_gongxu] = critical_path(P_chrom,Global,info);%寻找关键路径
    max_key = size(key_path,2);
      
    % 随机选择关键路径上的两道工序
    rand_site = randi([1,max_key],2,1);

    gongjian_1 = key_path(1,rand_site(1));
    gongxu_1 = key_path(2,rand_site(1));
    gongjian_2 = key_path(1,rand_site(2));
    gongxu_2 = key_path(2,rand_site(2));
    
    % 寻找进行交换的关键工序在染色体中的位置
    pos_1 = order_gongxu(gongjian_1,gongxu_1);
    pos_2 = order_gongxu(gongjian_2,gongxu_2);
    
    % 交换两个位置的工序顺序
    P_chrom(pos_1) = gongjian_2;
    P_chrom(pos_2) = gongjian_1;
    
    gongxu_count=ones(1,Global.I); %重新分配工序
    for j=1:n_Var
        cur_gongjian=P_chrom(j);
        if cur_gongjian==gongjian_1 || cur_gongjian==gongjian_2
            num_machine = info(cur_gongjian).gongxu(gongxu_count(cur_gongjian)).num_jichuang;
            
            if num_machine==1
                P_chrom(n_Var+j) = 1;
            else                
%                 cur_time = info(cur_gongjian).gongxu(gongxu_count(cur_gongjian)).data(:,2);
%                 [~,min_index] = min(cur_time);
%                 P_chrom(n_Var+j) = min_index;
                P_chrom(n_Var+j) = randperm(num_machine,1);
            end
            
        end
        gongxu_count(cur_gongjian) = gongxu_count(cur_gongjian)+1;
    end
    cur_fitness = Global.fun(P_chrom);
    if cur_fitness < individuals.fitness(index)
        individuals.chrom(index,:) = P_chrom;
        individuals.fitness(index) = cur_fitness;
    end
end
ret=individuals;
end

% 基于工件优先顺序的交叉（POX）
function ret=Cross_gai(individuals,sizepop,Global,info)
nVar = size(individuals.chrom,2)/2;
job_prob = ceil(0.3*Global.I); %交叉工件个数
cur_prob = ceil(0.7*sizepop); %交叉概率
rand_chrom = randi(sizepop,cur_prob,2);
for h=1:cur_prob
    index = rand_chrom(h,:);
    % 随机获取两个亲本
    P1_chrom = individuals.chrom(index(1),:);
    P1_gongxu = P1_chrom(1:nVar);% P1的工序部分
     
    P2_chrom = individuals.chrom(index(2),:);
    jobset = randperm(Global.I,job_prob);% 随机获取工件集
    % 进行交叉
    for i=1:numel(jobset)
        P2_gongxu = P2_chrom(1:nVar);% P2的工序部分
        % 获取亲本中包含工件集中工件工序的位置和顺序
        job_gongxu_P1 = find(P1_gongxu == jobset(i));
        job_gongxu_P2 = find(P2_gongxu == jobset(i));
        % 相应工序安排的机器
        job_machine_P1 = P1_chrom(nVar + job_gongxu_P1);%P1的机器安排
        gongjian_P2 = P2_gongxu(job_gongxu_P1);% 获取P1->P2,P2相应基因位的工件
        
        % 删除重合工件及其位置
        gongjian_chong = find(gongjian_P2 == jobset(i));%与jobset重合工件的位置索引
        gongjian_P2(gongjian_chong) = [];%删除P2中重合的工件
        
        gongxu_chong = job_gongxu_P1(gongjian_chong);%重合工件的位置
        for p=1:numel(gongxu_chong)
            %重合工件的位置在P2中的索引
            chong_index = find(job_gongxu_P2 == gongxu_chong(p));
            job_gongxu_P2(chong_index) = [];%P2中重合工件的位置
        end
        
        % 将P1复制到P2
        P2_chrom(job_gongxu_P1) = jobset(i);%将P2工序部分中P1对应的位置换为jobset
        %将P2机器部分中P1对应的位置换为jobset
        P2_chrom(nVar + job_gongxu_P1) = job_machine_P1;
        P2_chrom(job_gongxu_P2) = gongjian_P2;
        
        % 为P2对应P1位置上涉及的工件重新安排加工机器
        for j=1:numel(gongjian_P2)
            cur_gongjian = gongjian_P2(j);%获取当前工件
            gongxu_ji = find(P2_chrom(1:nVar) == cur_gongjian);%当前工件的所有工序
            for k=1:numel(gongxu_ji)
                % 当前工序的可用机器数量
                num_machine = info(cur_gongjian).gongxu(k).num_jichuang;
%                 P2_chrom(gongxu_ji(k) + nVar) = randperm(num_machine,1);
                
                if num_machine==1
                    P2_chrom(gongxu_ji(k) + nVar) = 1;
                else
                    cur_time = info(cur_gongjian).gongxu(k).data(:,2);
                    [~,min_index] = min(cur_time);
                    P2_chrom(gongxu_ji(k) + nVar) = min_index;
%                     P2_chrom(gongxu_ji(k) + nVar) = randperm(num_machine,1);
                end
                
            end
        end
    end

    cur_fitness = Global.fun(P2_chrom);
    if cur_fitness < individuals.fitness(index(2))
        individuals.chrom(index(2),:) = P2_chrom;
        individuals.fitness(index(2)) = cur_fitness;
    end
end
ret=individuals;
end

% 输入为工序排序与机器选择数组，输出关键路径
function [key,gongxu_order] = critical_path(x,Global,info)
nVar = numel(x);
% 从头到尾安排工件进行加工

% T_duidao = 0;                     %对刀时间
% T_jiagong = 0;                      %总加工时间
% T_kongxian = 0;                     %总空闲时间
T_start = zeros(Global.I,6); %各工件工序的开工时间
T_need = zeros(Global.I,6); %各工件工序所需的加工时间
T_end = zeros(Global.I,6); %各工件工序的完工时间
release_time = zeros(1,Global.M); %机器下一次的可用时间

gongxu_order = zeros(Global.I,6);%记录各工序在染色体上的顺序
use_machine = zeros(Global.I,6);%记录各工序使用的机器
machine_order = zeros(Global.M,6);%在同一机器上各工序的顺序
% 记录每个机器上的每道工序
mt_start = zeros(Global.M,6);%工序开工时间
mt_end = zeros(Global.M,6);%工序完工时间
m_gongjian = zeros(Global.M,6);%工件号
m_gongxu = zeros(Global.M,6);%工序号
% P_jiagong = 0;
% P_duidao = 0;
% P_kongxian = 0;

count_gongxu = ones(1,Global.I); %记录当前工序索引
count_machine = zeros(1,Global.M); %记录机器使用次数

for i=1:nVar/2
    cur_gongjian = x(i);%获取当前工件号
    cur_gongxu = count_gongxu(cur_gongjian);%读取当前工件此时的工序号
    cur_machine = x(nVar/2+i);%获取为当前工序安排的机器顺序号
    %获取当前工序的机器编号
    cur_machine_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao(cur_machine);
    % 记录当前工件当前工序的加工机器
    use_machine(cur_gongjian,cur_gongxu) = cur_machine_code;
    % 记录当前工件工序在染色体上的位置
    gongxu_order(cur_gongjian,cur_gongxu) = i;
    %将当前使用机器的使用次数+1
    count_machine(cur_machine_code) = count_machine(cur_machine_code) + 1;
    
    % 当前工件工序在同一机器上的加工顺序
    machine_order(cur_gongjian,cur_gongxu) = count_machine(cur_machine_code);
    
    if cur_gongxu==1 %当前工件是首个工序
        if release_time(cur_machine_code)>Global.Ai(cur_gongjian) %当前机床被占用
            % 当前工件的当前工序的开工时间 = 当前机器的下一次可用时间
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            % 当前工件的当前工序所需的加工时间->从info数据结构中索引
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            % 当前机器的下一次可用时间 ->需要叠加当前工序的加工时间
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = Global.Ai(cur_gongjian);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            
%             P_kongxian = P_kongxian + (T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code))*Global.m_power(cur_machine,1);
            % 计算空闲时间：当前工序的开工时间-当前机器的下一次可用时间；并累加
%             T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            % 当前机器的下一次可用时间 = 开工时间+所需加工时间
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
        % 计算加工时间并累加
%         T_jiagong = T_jiagong+info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
%         T_jiagong = T_jiagong + T_need(cur_gongjian,cur_gongxu);
        
%         T_duidao = T_duidao+Global.Ni(cur_gongjian)*sum(info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,3));
%         P_jiagong = P_jiagong + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,1)*Global.Ni(cur_gongjian);
%         P_duidao = P_duidao + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,3)* ...
%             Global.m_power(cur_machine_code,2)*Global.Ni(cur_gongjian);
            
        % 当前工件当前工序的完工时间 = 开工时间+所需加工时间
        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        
        % 记录机器开始/结束加工时间
        mt_start(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu);
        mt_end(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        m_gongjian(cur_machine_code,count_machine(cur_machine_code)) = cur_gongjian;
        m_gongxu(cur_machine_code,count_machine(cur_machine_code)) = cur_gongxu;
        
    else %当前工件不是首个工序
        if release_time(cur_machine_code)>T_end(cur_gongjian,cur_gongxu-1) %当前机床被占用
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = T_end(cur_gongjian,cur_gongxu-1);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            
%             P_kongxian = P_kongxian + (T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code))*Global.m_power(cur_machine,1);

%             T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
%         T_jiagong = T_jiagong+T_need(cur_gongjian,cur_gongxu);
%         P_jiagong = P_jiagong + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,1)*Global.Ni(cur_gongjian);
        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        
        % 记录机器开始/结束加工时间
        mt_start(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu);
        mt_end(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        m_gongjian(cur_machine_code,count_machine(cur_machine_code)) = cur_gongjian;
        m_gongxu(cur_machine_code,count_machine(cur_machine_code)) = cur_gongxu;  
    end
    %将当前工件此时的工序号+1，指向下一工序
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
end

T_total = max(release_time);%寻找机器下一次可用时间的最大值

% 寻找最大完工时间的机器，开始寻找关键路径
max_time_machine = find(release_time == T_total);
tail_gongjian_set = zeros(1,numel(max_time_machine));
tail_gongxu_set = zeros(1,numel(max_time_machine));
% 记录最大完工时间机器的尾工件工序
for i=1:numel(max_time_machine)
    tail_gongjian_set(i) = m_gongjian(max_time_machine(i),count_machine(max_time_machine(i)));%尾工件集
    tail_gongxu_set(i) = m_gongxu(max_time_machine(i),count_machine(max_time_machine(i)));%尾工序集
end
key = zeros(2,2);%记录关键路径
% 逐个机器搜索
% for i=1:numel(max_time_machine)
    i = randperm(numel(max_time_machine),1);
    cur_tail_gongjian = tail_gongjian_set(i);
    cur_tail_gongxu = tail_gongxu_set(i);
    for j=1:1000
        now_gongjian = cur_tail_gongjian;
        now_gongxu = cur_tail_gongxu;
        % 当前工件工序的加工机器
        now_machine = use_machine(now_gongjian,now_gongxu);
        % 当前工件工序在加工机器中的顺序
        now_machine_order = machine_order(now_gongjian,now_gongxu);
        % 当前工序的开工时间=0则搜寻结束
        if mt_start(now_machine,now_machine_order) == 0
            key(1,j) = now_gongjian;
            key(2,j) = now_gongxu;
            key(3,j) = gongxu_order(key(1,j),key(2,j));
            break;
        end
        % 当前工序为当前机器的首道工序
        if now_machine_order==1
            key(1,j) = now_gongjian;
            key(2,j) = now_gongxu;
            key(3,j) = gongxu_order(key(1,j),key(2,j));
            cur_tail_gongjian = now_gongjian;
            cur_tail_gongxu = now_gongxu-1;
            % 当前工序的开工时间=前道工序的完工时间，则为关键工序
        elseif mt_start(now_machine,now_machine_order) == mt_end(now_machine,now_machine_order-1)
            key(1,j) = now_gongjian;
            key(2,j) = now_gongxu;
            key(3,j) = gongxu_order(key(1,j),key(2,j));
            cur_tail_gongjian = m_gongjian(now_machine,now_machine_order-1);
            cur_tail_gongxu = m_gongxu(now_machine,now_machine_order-1);
        % 否则索引当前工序的同一工件的前道工序，为尾工序
        else
            key(1,j) = now_gongjian;
            key(2,j) = now_gongxu;
            key(3,j) = gongxu_order(key(1,j),key(2,j));
            cur_tail_gongjian = now_gongjian;
            cur_tail_gongxu = now_gongxu-1;
        end
    end
end

% 工序选择部分变异
function ret=Mut_gongxu_key(individuals,sizepop,Global,info)
cur_mut = 4;
cur_prob = ceil(0.01*sizepop);
Mut = randperm(sizepop,cur_prob);
nVar = size(individuals.chrom,2)/2;
for i=1:cur_prob
    % 随机选择染色体进行自变异
    index = Mut(i);
    chose_chrom = individuals.chrom(index,:);
    tmp_chrom = chose_chrom;
    best_neighbor = chose_chrom;   
    best_fit = Global.fun(tmp_chrom);  
    [path_key,~] = critical_path(tmp_chrom,Global,info);
    key_max = size(path_key,2);
%     cur_mut = ceil(0.2*key_max);
    pos = randperm(key_max,cur_mut);% 随机选择r个基因位
    chrom_pos = path_key(3,pos);
    neighbor = perms(chrom_pos);%ｒ个不同基因，生成其排序的所有邻域
    
%     select_num = cur_mut;
%     select_neighbor = randperm(size(neighbor,1),select_num); % 选择部分邻域进行评价
    
    % 评价所有邻域的适应值，选出最佳个体作为子代
    for j=1:size(neighbor,1)-1
%     for select_j=1:select_num
%         j = select_neighbor(select_j);
        cur_neighbor = neighbor(j,:);%当前邻域排序
        tmp_chrom(chrom_pos) = chose_chrom(cur_neighbor);%获取当前邻域的个体
        
        cur_gongxu=ones(1,Global.I); %重新分配工序
        for k=1:nVar
            cur_gongjian=tmp_chrom(k);
          
            %为涉及到的工件的所有工序随机安排机器
            if find(tmp_chrom(chrom_pos)==cur_gongjian)
                num_machine = info(cur_gongjian).gongxu(cur_gongxu(cur_gongjian)).num_jichuang;
%                 tmp_chrom(nVar+k) = randperm(num_machine,1);% 随机安排机器
                
                if num_machine==1
                    tmp_chrom(nVar+k) = 1;
                else
                    cur_time = info(cur_gongjian).gongxu(cur_gongxu(cur_gongjian)).data(:,2);
                    [~,min_index] = min(cur_time);
                    tmp_chrom(nVar+k) = min_index;
%                     tmp_chrom(nVar+k) = randperm(num_machine,1);% 随机安排机器
                end

            end
            cur_gongxu(cur_gongjian) = cur_gongxu(cur_gongjian)+1;
        end
        cur_fitness = Global.fun(tmp_chrom);%计算当前邻域的适应值
        %记录最佳适应值个体
        if (cur_fitness < best_fit)
            best_fit = cur_fitness;
            best_neighbor = tmp_chrom;
        end
        tmp_chrom = chose_chrom;
    end
    individuals.chrom(index,:) = best_neighbor;
    individuals.fitness(index) = best_fit;
end
ret=individuals;
end

% 机器选择部分变异
function ret=Mut_mach_key(individuals,sizepop,Global,info)
nVar = size(individuals.chrom,2)/2;
mut_prob = 4;%控制变异基因位
cur_prob = ceil(0.1*sizepop);%控制变异率为0.03
Mut = randperm(sizepop,cur_prob);
for i=1:cur_prob
    % 随机选择染色体进行自变异
    index = Mut(i);
    tmp_chrom = individuals.chrom(index,:);
    
    best_chrom = tmp_chrom;
    best_fitness = individuals.fitness(index);
    
    [path_key,gongxu_order] = critical_path(tmp_chrom,Global,info);
    key_max = size(path_key,2);
    
    cur_mut = mut_prob;
    pos = randperm(key_max,cur_mut);
    
    pos_gongjian = path_key(1,pos);%获取基因位对应的工件
    pos_gongxu = path_key(2,pos);%获取基因位对应工件的工序

    %对机器选择部分：“变异基因位”选择“总加工时间最短”的机器
    for j=1:cur_mut
        %获取当前工件
        cur_gongjian = pos_gongjian(j);
        %获取当前工件的工序
        cur_gongxu = pos_gongxu(j);
        %获取当前工序可用机器的数量
        num_machine = info(cur_gongjian).gongxu(cur_gongxu).num_jichuang;

        % 选择使得总加工时间最小的加工机器
        if num_machine > 1
            for k=1:num_machine
                %获取当前工件工序在染色体中的顺序号
                cur_order = gongxu_order(cur_gongjian,cur_gongxu);
                tmp_chrom(nVar + cur_order) = k;
                tmp_fitness = Global.fun(tmp_chrom);
                if tmp_fitness < best_fitness
                    best_chrom = tmp_chrom;
                    best_fitness = tmp_fitness;
                end
            end
        end
    end
    individuals.chrom(index,:) = best_chrom;
    individuals.fitness(index) = best_fitness;
end
ret=individuals;
end

%% CWPFJSP_TM模型 画甘特图
function [] = Draw_Gantt(bestchrom,Global,info)
x = bestchrom;
nVar = numel(x(1,:));

[y,RT,used_device,T_start,T_need,~,...
    ~,~,~] = fun_cwp(x,Global,info);
% 画甘特图
color = parula(2*Global.I+1);
count_gongxu = ones(1,Global.I);
for i =1:nVar/2
    cur_gongjian = x(1,i);
    cur_gongxu = count_gongxu(cur_gongjian);
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;

    cur_clamping_code = used_device.C(cur_gongjian,cur_gongxu);
    rec(1) = T_start.C(cur_gongjian,cur_gongxu);    %矩形的横坐标
    rec(2) = cur_clamping_code-0.5;                 %矩形的纵坐标
    rec(3) = T_need.C(cur_gongjian,cur_gongxu);     %矩形的x轴方向的长度
    rec(4) = 1;                                     %矩形的高度
    txt=sprintf('C%d-%d',cur_gongjian,cur_gongxu);%将机器号，工序号，加工时间连城字符串
    rectangle('Position' ,rec,'LineWidth',2,'LineStyle','-','FaceColor',[0.8,0.8,0.8],'EdgeColor','r');%draw every rectangle
    text(T_start.C(cur_gongjian,cur_gongxu)+0.1,cur_clamping_code,txt,'Color','k','FontWeight','Bold','FontSize',10, ...
        'HorizontalAlignment','left');%label the id of every task  ，字体的坐标和其它特性   

    cur_waiting_code = used_device.W(cur_gongjian,cur_gongxu);
    rec(1) = T_start.W(cur_gongjian,cur_gongxu);    %矩形的横坐标
    rec(2) = cur_waiting_code + Global.C + 1-0.5;       %矩形的纵坐标
    rec(3) = T_need.W(cur_gongjian,cur_gongxu);     %矩形的x轴方向的长度
    rec(4) = 1;                                     %矩形的高度
    txt=sprintf('W%d-%d',cur_gongjian,cur_gongxu);%将机器号，工序号，加工时间连城字符串
    rectangle('Position' ,rec,'LineWidth',2,'LineStyle','-','FaceColor',[0.8,0.8,0.8],'EdgeColor','b');%draw every rectangle
    text(T_start.W(cur_gongjian,cur_gongxu)+0.1,cur_waiting_code + Global.C + 1,txt,'Color','k','FontWeight','Bold','FontSize',10, ...
        'HorizontalAlignment','left');%label the id of every task  ，字体的坐标和其它特性   

    cur_machine_code = used_device.M(cur_gongjian,cur_gongxu);    
    rec(1) = T_start.M(cur_gongjian,cur_gongxu);            %矩形的横坐标
    rec(2) = cur_machine_code + Global.C + Global.W + 2 -0.5;    %矩形的纵坐标
    rec(3) = T_need.M(cur_gongjian,cur_gongxu);             %矩形的x轴方向的长度
    rec(4) = 1;                                             %矩形的y轴方向的长度
    txt=sprintf('P%d-%d',cur_gongjian,cur_gongxu);%将机器号，工序号，加工时间连城字符串
    rectangle('Position' ,rec,'LineWidth',0.5,'LineStyle','-','FaceColor',color(2*cur_gongjian,:));%draw every rectangle
    text(T_start.M(cur_gongjian,cur_gongxu)+0.1,cur_machine_code + Global.C + Global.W + 2,txt, ...
        'Color','k','FontWeight','Bold','FontSize',10,'HorizontalAlignment','left');%label the id of every task,字体的坐标和其它特性   


end

num_device = Global.C + Global.W + Global.M + 2;
yticks(1:1:num_device)

cur_ylabel = {};
for i=1:Global.C
    cur_ylabel{end+1} = strcat('C',num2str(i));
end
cur_ylabel{end+1} = ' ';
for i=1:Global.W
    cur_ylabel{end+1} = strcat('W',num2str(i));
end
cur_ylabel{end+1} = ' ';
for i=1:Global.M
    cur_ylabel{end+1} = strcat('M',num2str(i));
end
% yticklabels({'C1','C2','C3','W1','W2','W3','W4','M1','M2','M3','M4'})
yticklabels(cur_ylabel);
title('甘特图','FontSize',14)
grid on
box on
hold on
xlabel('时间/分钟','FontSize',14)
ylabel('设备序号') %机床序号
end
 
%% 画甘特图（测试用）
function []=draw_gantt(bestchrom,Global,info)
x=bestchrom;
nVar = numel(x);

[~,~,use_machine,~,T_start,T_need,~,...
    ~,~,~,~] = out_data(x,Global,info);
% 画甘特图
color = parula(Global.I);
count_gongxu=ones(1,Global.I);
for i =1:nVar/2
    cur_gongjian = bestchrom(i);
    cur_gongxu = count_gongxu(cur_gongjian);
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
    cur_machine_code = use_machine(cur_gongjian,cur_gongxu);
    
    rec(1) = T_start(cur_gongjian,cur_gongxu);%矩形的横坐标
    rec(2) = cur_machine_code-0.5;  %矩形的纵坐标
    rec(3) = T_need(cur_gongjian,cur_gongxu);  %矩形的x轴方向的长度
    rec(4) = 1;

    if rem(cur_gongxu,3) == 1
        txt=sprintf('O%d%d\n(C%d%d)',cur_gongjian,ceil(cur_gongxu/3),cur_gongjian,ceil(cur_gongxu/3));%将机器号，工序号，加工时间连成字符串    
    elseif rem(cur_gongxu,3) == 2
        txt=sprintf('O%d%d\n(W%d%d)',cur_gongjian,ceil(cur_gongxu/3),cur_gongjian,ceil(cur_gongxu/3));
    else 
        txt=sprintf('O%d%d\n(P%d%d)',cur_gongjian,ceil(cur_gongxu/3),cur_gongjian,ceil(cur_gongxu/3));
    end

    rectangle('Position' ,rec,'LineWidth',1.15,'LineStyle','-','FaceColor',color(cur_gongjian,:));%draw every rectangle
    text(T_start(cur_gongjian,cur_gongxu)+0.2,cur_machine_code,txt,'Color','k','FontWeight','Bold','FontSize',10, ...
        'HorizontalAlignment','left');%label the id of every task  ，字体的坐标和其它特性
end
yticks(1:1:Global.M)
yticklabels({'C1','C2','C3','W1','W2','W3','W4','M1','M2','M3','M4'})
title('甘特图','FontSize',14)
grid on
box on
hold on
xlabel('时间/分钟','FontSize',14)
ylabel('') %机床序号
end
 
%% 画甘特图，并输出相关数据
function [T_total,release_time,use_machine,machine_order,T_start,T_need,T_end,...
    m_gongjian,m_gongxu,mt_start,mt_end] = draw_gai(bestchrom,Global,info,num)
figure(num)
x=bestchrom;
nVar = numel(x);

[T_total,release_time,use_machine,machine_order,T_start,T_need,T_end,...
    m_gongjian,m_gongxu,mt_start,mt_end] = out_data(x,Global,info);
% 画甘特图
color = parula(Global.I);
count_gongxu=ones(1,Global.I);
for i =1:nVar/2
    cur_gongjian = bestchrom(i);
    cur_gongxu = count_gongxu(cur_gongjian);
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
    cur_machine_code = use_machine(cur_gongjian,cur_gongxu);
    
    rec(1) = T_start(cur_gongjian,cur_gongxu);%矩形的横坐标
    rec(2) = cur_machine_code-0.5;  %矩形的纵坐标
    rec(3) = T_need(cur_gongjian,cur_gongxu);  %矩形的x轴方向的长度
    rec(4) = 1;
    txt=sprintf('(%d-%d)',cur_gongjian,cur_gongxu);%将机器号，工序号，加工时间连城字符串
    rectangle('Position' ,rec,'LineWidth',1.15,'LineStyle','-','FaceColor',color(cur_gongjian,:));%draw every rectangle
    text(T_start(cur_gongjian,cur_gongxu),cur_machine_code,txt,'FontWeight','Bold','FontSize',8);%label the id of every task  ，字体的坐标和其它特性
end
yticks(0:1:Global.M)
title('甘特图')
grid on
box on
hold on
xlabel('时间/分钟')
ylabel('机床序号')
end

% 画甘特图
function draw_num = draw(bestchrom,Global,use_machine,T_start,T_need,num)
draw_num = num;
figure(num);
x = bestchrom;
nVar = numel(x);
color = parula(Global.I);
count_gongxu=ones(1,Global.I);
for i =1:nVar/2
    cur_gongjian = x(i);
    cur_gongxu = count_gongxu(cur_gongjian);
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
    cur_machine_code = use_machine(cur_gongjian,cur_gongxu);
    
    rec(1) = T_start(cur_gongjian,cur_gongxu);%矩形的横坐标
    rec(2) = cur_machine_code-0.5;  %矩形的纵坐标
    rec(3) = T_need(cur_gongjian,cur_gongxu);  %矩形的x轴方向的长度
    rec(4) = 1;
    txt=sprintf('(%d-%d)',cur_gongjian,cur_gongxu);%将机器号，工序号，加工时间连城字符串
    rectangle('Position' ,rec,'LineWidth',1.15,'LineStyle','-','FaceColor',color(cur_gongjian,:));%draw every rectangle
    text(T_start(cur_gongjian,cur_gongxu),cur_machine_code,txt,'FontWeight','Bold','FontSize',8);%label the id of every task  ，字体的坐标和其它特性
end  
yticks(0:1:Global.M)
title('甘特图')
grid on
box on
hold off
xlabel('时间/分钟')
ylabel('机床序号')
end

% 输出：各工序：开工时间T_start、完工时间T_end、加工时间T_need、所使用机器use_machine
% 各机器上的每道工序：工件号m_gongjian、工序号m_gongxu、开工时间mt_start、完工时间mt_end
% 输入：bestchrom
function [T_total,release_time,use_machine,machine_order,T_start,T_need,T_end,...
    m_gongjian,m_gongxu,mt_start,mt_end] = out_data(x,Global,info)
nVar = numel(x);
% 从头到尾安排工件进行加工

% T_duidao = 0;                     %对刀时间
% T_jiagong = 0;                      %总加工时间
% T_kongxian = 0;                     %总空闲时间
T_start = zeros(Global.I,6); %各工件工序的开工时间
T_need = zeros(Global.I,6); %各工件工序所需的加工时间
T_end = zeros(Global.I,6); %各工件工序的完工时间
release_time = zeros(1,Global.M); %机器下一次的可用时间

gongxu_order = zeros(Global.I,6);%记录各工序在染色体上的顺序
use_machine = zeros(Global.I,6);%记录各工序使用的机器
machine_order = zeros(Global.M,6);%在同一机器上各工序的顺序
% 记录每个机器上的每道工序
mt_start = zeros(Global.M,6);%工序开工时间
mt_end = zeros(Global.M,6);%工序完工时间
m_gongjian = zeros(Global.M,6);%工件号
m_gongxu = zeros(Global.M,6);%工序号
% P_jiagong = 0;
% P_duidao = 0;
% P_kongxian = 0;

count_gongxu = ones(1,Global.I); %记录当前工序索引
count_machine = zeros(1,Global.M); %记录机器使用次数

for i=1:nVar/2
    cur_gongjian = x(i);%获取当前工件号
    cur_gongxu = count_gongxu(cur_gongjian);%读取当前工件此时的工序号
    cur_machine = x(nVar/2+i);%获取为当前工序安排的机器顺序号
    %获取当前工序的机器编号
    cur_machine_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao(cur_machine);
    % 记录当前工件当前工序的加工机器
    use_machine(cur_gongjian,cur_gongxu) = cur_machine_code;
    % 记录当前工件工序在染色体上的位置
    gongxu_order(cur_gongjian,cur_gongxu) = i;
    %将当前使用机器的使用次数+1
    count_machine(cur_machine_code) = count_machine(cur_machine_code) + 1;
    
    % 当前工件工序在同一机器上的加工顺序
    machine_order(cur_gongjian,cur_gongxu) = count_machine(cur_machine_code);
    
    if cur_gongxu==1 %当前工件是首个工序
        if release_time(cur_machine_code)>Global.Ai(cur_gongjian) %当前机床被占用
            % 当前工件的当前工序的开工时间 = 当前机器的下一次可用时间
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            % 当前工件的当前工序所需的加工时间->从info数据结构中索引
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            % 当前机器的下一次可用时间 ->需要叠加当前工序的加工时间
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = Global.Ai(cur_gongjian);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);

%             P_kongxian = P_kongxian + (T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code))*Global.m_power(cur_machine,1);
            % 计算空闲时间：当前工序的开工时间-当前机器的下一次可用时间；并累加
%             T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            % 当前机器的下一次可用时间 = 开工时间+所需加工时间
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
        % 计算加工时间并累加
%         T_jiagong = T_jiagong+info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
%         T_jiagong = T_jiagong + T_need(cur_gongjian,cur_gongxu);
        
%         T_duidao = T_duidao+Global.Ni(cur_gongjian)*sum(info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,3));
%         P_jiagong = P_jiagong + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,1)*Global.Ni(cur_gongjian);
%         P_duidao = P_duidao + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,3)* ...
%             Global.m_power(cur_machine_code,2)*Global.Ni(cur_gongjian);
            
        % 当前工件当前工序的完工时间 = 开工时间+所需加工时间
        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        
        % 记录机器开始/结束加工时间
        mt_start(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu);
        mt_end(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        m_gongjian(cur_machine_code,count_machine(cur_machine_code)) = cur_gongjian;
        m_gongxu(cur_machine_code,count_machine(cur_machine_code)) = cur_gongxu;
        
    else %当前工件不是首个工序
        if release_time(cur_machine_code)>T_end(cur_gongjian,cur_gongxu-1) %当前机床被占用
            T_start(cur_gongjian,cur_gongxu) = release_time(cur_machine_code);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            release_time(cur_machine_code) = release_time(cur_machine_code) + T_need(cur_gongjian,cur_gongxu);
        else %当前机床没有被占用
            T_start(cur_gongjian,cur_gongxu) = T_end(cur_gongjian,cur_gongxu-1);
            T_need(cur_gongjian,cur_gongxu) = info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,2);
            
%             P_kongxian = P_kongxian + (T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code))*Global.m_power(cur_machine,1);

%             T_kongxian = T_kongxian+(T_start(cur_gongjian,cur_gongxu)-release_time(cur_machine_code));
            release_time(cur_machine_code) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        end
%         T_jiagong = T_jiagong+T_need(cur_gongjian,cur_gongxu);
%         P_jiagong = P_jiagong + info(cur_gongjian).gongxu(cur_gongxu).data(cur_machine,1)*Global.Ni(cur_gongjian);
        T_end(cur_gongjian,cur_gongxu) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        
        % 记录机器开始/结束加工时间
        mt_start(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu);
        mt_end(cur_machine_code,count_machine(cur_machine_code)) = T_start(cur_gongjian,cur_gongxu) + T_need(cur_gongjian,cur_gongxu);
        m_gongjian(cur_machine_code,count_machine(cur_machine_code)) = cur_gongjian;
        m_gongxu(cur_machine_code,count_machine(cur_machine_code)) = cur_gongxu;
        
    end
    %将当前工件此时的工序号+1，指向下一工序
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
end
T_total = max(release_time);%寻找机器下一次可用时间的最大值
end

% 染色体解码，生成任务清单
function task = Dcode(bestchrom,task_name,Global,info)
x = bestchrom;
nVar = numel(x);
count_gongxu=ones(1,Global.I);
count_machine = ones(1,Global.M);
char task_machine;

for i =1:nVar/2
    %解码工序序列
    cur_gongjian = bestchrom(i);
    cur_gongxu = count_gongxu(cur_gongjian);
    count_gongxu(cur_gongjian) = count_gongxu(cur_gongjian)+1;
    %解码工序对应的机器
    cur_machine = bestchrom(nVar/2+i);
    cur_machine_code = info(cur_gongjian).gongxu(cur_gongxu).bianhao(cur_machine);
    count_machine(cur_machine_code) = count_machine(cur_machine_code)+1;
    machine_oder = count_machine(cur_machine_code);
    %生成机器任务清单-字符串数组
    task_machine(1,cur_machine_code) = sprintf("机器%d",cur_machine_code);    
    task_machine(machine_oder,cur_machine_code) = sprintf("%d_%d",cur_gongjian,cur_gongxu);
end
%将任务清单（字符串）写入表格
task = xlswrite(task_name,task_machine);
end
%%



 
