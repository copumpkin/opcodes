{-# LANGUAGE ForeignFunctionInterface #-}
module Architecture.Opcodes.Internal where

import Foreign.C
import Foreign.C.Types
import Foreign.C.String

import Foreign.Ptr
import Foreign.Storable

import Data.IORef

import Data.ByteString (ByteString)
import qualified Data.ByteString as B
import Data.ByteString.Unsafe

import System.IO.Unsafe

import Control.Arrow

newtype DecoderPtr = DecoderPtr (FunPtr DecoderPtr)

foreign import ccall "&print_insn_i386_att" i386_att :: DecoderPtr
foreign import ccall "&print_insn_i386_intel" i386_intel :: DecoderPtr
foreign import ccall "&print_insn_big_arm" big_arm :: DecoderPtr
foreign import ccall "&print_insn_little_arm" little_arm :: DecoderPtr

foreign import ccall "shim_decode" shim_decode :: DecoderPtr -> FunPtr (CString -> IO ()) -> CLong -> CLong -> Ptr a -> CSize -> IO CSize

foreign import ccall "wrapper" wrap :: (CString -> IO ()) -> IO (FunPtr (CString -> IO ()))


stringAppender :: IO (CString -> IO (), IO String)
stringAppender = do
  ref <- newIORef id
  let writer str = do
        str <- peekCString str
        modifyIORef ref (. (str ++))
  return (writer, fmap ($ "") (readIORef ref))

decodeIO :: DecoderPtr -> Int -> ByteString -> IO (String, ByteString)
decodeIO dec loc buf = do
  (update, read) <- stringAppender
  updateIO <- wrap update
  len <- unsafeUseAsCStringLen buf (uncurry (shim_decode dec updateIO 3 (fromIntegral loc)) . second fromIntegral)
  str <- read
  return (str, B.drop (fromIntegral len) buf)
  
decodePure :: DecoderPtr -> Int -> ByteString -> (String, ByteString)
decodePure dec loc buf = unsafePerformIO (decodeIO dec loc buf)