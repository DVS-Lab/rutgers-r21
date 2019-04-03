clear; close all;
c1 = load('PreCun_func_type-ppi_cope-11.txt');
c2 = load('PreCun_func_type-ppi_cope-12.txt');
c3 = load('PreCun_func_type-ppi_cope-13.txt');
c4 = load('PreCun_func_type-ppi_cope-14.txt');

reward = [c1 c2];
punish = [c3 c4];
figure, barweb_dvs2([mean(reward); mean(punish)],[std(reward)/sqrt(length(reward)); std(punish)/sqrt(length(punish)) ])
axis square
print -depsc conn_PreCun-NAcc


c1 = load('NAcc_type-act_cope-01.txt');
c2 = load('NAcc_type-act_cope-02.txt');
c3 = load('NAcc_type-act_cope-03.txt');
c4 = load('NAcc_type-act_cope-04.txt');

reward = [c1 c2];
punish = [c3 c4];
figure, barweb_dvs2([mean(reward); mean(punish)],[std(reward)/sqrt(length(reward)); std(punish)/sqrt(length(punish)) ])
axis square
print -depsc act_NAcc

