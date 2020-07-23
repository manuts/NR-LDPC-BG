function y = mul_sh(x,k)
%x: input block
%k: -1 or shift
%y: output

if (k==-1)
    y = zeros(1,length(x));
else
    y = [x(k+1:end) x(1:k)]; %multiplication by shifted identity
end
