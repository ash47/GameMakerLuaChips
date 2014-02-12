Require("binary")

-- Need to rewrite these conversions, will do for now:

function D2H(IN)
    local B,K,OUT,I,D=16,"0123456789ABCDEF","",0
    while IN>0 do
        I=I+1
        IN,D=math.floor(IN/B),math.mod(IN,B)+1
        OUT=string.sub(K,D,D)..OUT
    end
	--Make sure it outputs the entire hex decimal:
	if(string.len(OUT)==0)then OUT = "00" elseif(string.len(OUT)==1)then OUT="0"..OUT end
    return OUT
end

function read_word(f)
	local s,i="",1;
	for i=0,1 do
		s = D2H(read_byte(f))..s;
	end
	--return H2D(s);
	return tonumber(tonumber(s, 16).."");
end

function read_long(f)
	local s,i="",1;
	for i=0,3 do
		s = D2H(read_byte(f))..s;
	end
	return s;
end
