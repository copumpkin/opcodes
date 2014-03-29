#!/usr/bin/env runhaskell

import Control.Monad

import Distribution.Simple
import Distribution.Simple.Setup
import Distribution.Simple.Utils
import Distribution.Simple.Command
import Distribution.Verbosity
import Distribution.PackageDescription
import Distribution.PackageDescription.Parse

import System.Directory

binutilsVersion = "2.24"
binutilsPath = "cbits/opcodes-" ++ binutilsVersion

getHookedBuildInfo :: Verbosity -> IO HookedBuildInfo
getHookedBuildInfo verbosity = do
  maybe_infoFile <- defaultHookedPackageDesc
  case maybe_infoFile of
    Nothing       -> return emptyHookedBuildInfo
    Just infoFile -> do
      info verbosity $ "Reading parameters from " ++ infoFile
      readHookedBuildInfo verbosity infoFile

hooks :: UserHooks
hooks = autoconfUserHooks { postConf = postConfHook }
  where
  -- We need to call configure in our opcodes directory, then get make to configure bfd, then get make to make our bfd.h.
  -- This gets us a config.h and a bfd.h that we need to compile the code we want.
  postConfHook args flags pkg_descr lbi = do
    let verbosity = fromFlag (configVerbosity flags)
    oldDirectory <- getCurrentDirectory
    setCurrentDirectory binutilsPath
    noExtraFlags args
    confExists <- doesFileExist "configure"
    if confExists
      then rawSystemExit verbosity "sh" $ "configure" : configureArgs True flags ++ ["--enable-targets=all", "--disable-nls", "--enable-64bit-bfd"]
      else die "configure script not found."
    
    rawSystemExit verbosity "make" ["configure-bfd"]
    setCurrentDirectory "bfd"
    rawSystemExit verbosity "make" ["bfd.h"]  

    setCurrentDirectory oldDirectory

    pbi <- getHookedBuildInfo verbosity
    let pkg_descr' = updatePackageDescription pbi pkg_descr
    postConf simpleUserHooks args flags pkg_descr' lbi


main :: IO ()
main = defaultMainWithHooks hooks