function dcdt = shakeFlaskModel(t,c,theta,Ks1,Ks2)
dcdt = zeros(3,1);
qs1max = theta(1);
qs2max = theta(2);
YXS1 = theta(3);
YXS2 = theta(4);
Ks2app = Ks2+(Ks2/Ks1)*c(2);
qs1 = qs1max*(c(1)/(c(1)+Ks1));
qs2 = qs2max*(c(2)/(c(2)+Ks2app));
mu = qs1*YXS1+qs2*YXS2;
dcdt(1) = mu*c(1);
dcdt(2) = -qs1*c(1);
dcdt(3) = -qs2*c(1);
end