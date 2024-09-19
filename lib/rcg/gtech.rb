module RCG
  class Inv < Gate1
  end

  class Buf < Gate1
  end

  class And2 < Gate2
  end

  class Or2 < Gate2
  end

  class Xor2 < Gate2
  end

  class Nand2 < Gate2
  end

  class Nor2 < Gate2
  end
  
  GTECH=[Inv,And2,Or2,Xor2,Nand2,Nor2]
end
