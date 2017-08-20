function tf = within(x,a,b)
if b<a b = b+360; end
tf = (x>=a & x<b) | ((x+360)>=a & (x+360)<b) | ((x-360)>=a & (x-360)<b);