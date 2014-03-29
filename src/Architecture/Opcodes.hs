module Architecture.Opcodes
  ( decode
  , Endian(Little, Big)
  , X86Syntax(ATT, ATTSuffix, Intel)
  , X86Type(X86_64T, I386T, I8086T)
  , ARMType(ARMT, ThumbT)
  , ARMRegs(StdRegs, APCRegs, RawRegs)
  , Architecture(X86, ARM)
  ) where

import Data.Map (Map)
import qualified Data.Map as Map
import Data.ByteString (ByteString)
import qualified Data.ByteString as B

import Architecture.Opcodes.Internal

data Endian = Little | Big
  deriving (Show, Read, Eq, Ord, Enum)

data X86Syntax = ATT | ATTSuffix | Intel
  deriving (Show, Read, Eq, Ord, Enum)

data X86Type = X86_64T | I386T | I8086T
  deriving (Show, Read, Eq, Ord, Enum)

data ARMType = ARMT | ThumbT
  deriving (Show, Read, Eq, Ord, Enum)

data ARMRegs = StdRegs | APCRegs | RawRegs
  deriving (Show, Read, Eq, Ord, Enum)

data Architecture 
  = X86 X86Type X86Syntax
  | ARM Endian ARMType ARMRegs
  deriving (Show, Read, Eq, Ord)

type Decoder = Int -> ByteString -> (String, ByteString)

decoderPtr :: Architecture -> DecoderPtr
decoderPtr (X86 _ ATT) = i386_att
decoderPtr (X86 _ Intel) = i386_intel
decoderPtr (ARM Big ThumbT _) = big_arm
decoderPtr (ARM Little ARMT _) = little_arm
decoderPtr (ARM Big ARMT _) = big_arm
decoderPtr (ARM Little ThumbT _) = little_arm

  

decode :: Architecture -> Int -> ByteString -> (String, ByteString)
decode = decodePure . decoderPtr
