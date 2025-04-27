# space
ui_print " "

# var
UID=`id -u`
[ ! "$UID" ] && UID=0
FIRARCH=`grep_get_prop ro.bionic.arch`
SECARCH=`grep_get_prop ro.bionic.2nd_arch`
ABILIST=`grep_get_prop ro.product.cpu.abilist`
if [ ! "$ABILIST" ]; then
  ABILIST=`grep_get_prop ro.system.product.cpu.abilist`
fi
if [ "$FIRARCH" == arm64 ]\
&& ! echo "$ABILIST" | grep -q arm64-v8a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,arm64-v8a"
  else
    ABILIST=arm64-v8a
  fi
fi
if [ "$FIRARCH" == x64 ]\
&& ! echo "$ABILIST" | grep -q x86_64; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86_64"
  else
    ABILIST=x86_64
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi"
  else
    ABILIST=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST" | grep -q armeabi-v7a; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,armeabi-v7a"
  else
    ABILIST=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST" | grep -q x86; then
  if [ "$ABILIST" ]; then
    ABILIST="$ABILIST,x86"
  else
    ABILIST=x86
  fi
fi
ABILIST32=`grep_get_prop ro.product.cpu.abilist32`
if [ ! "$ABILIST32" ]; then
  ABILIST32=`grep_get_prop ro.system.product.cpu.abilist32`
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi"
  else
    ABILIST32=armeabi
  fi
fi
if [ "$SECARCH" == arm ]\
&& ! echo "$ABILIST32" | grep -q armeabi-v7a; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,armeabi-v7a"
  else
    ABILIST32=armeabi-v7a
  fi
fi
if [ "$SECARCH" == x86 ]\
&& ! echo "$ABILIST32" | grep -q x86; then
  if [ "$ABILIST32" ]; then
    ABILIST32="$ABILIST32,x86"
  else
    ABILIST32=x86
  fi
fi
if [ ! "$ABILIST32" ]; then
  [ -f /system/lib/libandroid.so ] && ABILIST32=true
fi

# log
if [ "$BOOTMODE" != true ]; then
  FILE=/data/media/"$UID"/$MODID\_recovery.log
  ui_print "- Log will be saved at $FILE"
  exec 2>$FILE
  ui_print " "
fi

# optionals
OPTIONALS=/data/media/"$UID"/optionals.prop
if [ ! -f $OPTIONALS ]; then
  touch $OPTIONALS
fi

# debug
if [ "`grep_prop debug.log $OPTIONALS`" == 1 ]; then
  ui_print "- The install log will contain detailed information"
  set -x
  ui_print " "
fi

# recovery
if [ "$BOOTMODE" != true ]; then
  MODPATH_UPDATE=`echo $MODPATH | sed 's|modules/|modules_update/|g'`
  rm -f $MODPATH/update
  rm -rf $MODPATH_UPDATE
fi

# run
. $MODPATH/function.sh

# info
MODVER=`grep_prop version $MODPATH/module.prop`
MODVERCODE=`grep_prop versionCode $MODPATH/module.prop`
ui_print " ID=$MODID"
ui_print " Version=$MODVER"
ui_print " VersionCode=$MODVERCODE"
if [ "$KSU" == true ]; then
  ui_print " KSUVersion=$KSU_VER"
  ui_print " KSUVersionCode=$KSU_VER_CODE"
  ui_print " KSUKernelVersionCode=$KSU_KERNEL_VER_CODE"
  sed -i 's|#k||g' $MODPATH/post-fs-data.sh
else
  ui_print " MagiskVersion=$MAGISK_VER"
  ui_print " MagiskVersionCode=$MAGISK_VER_CODE"
fi
ui_print " "

# sdk
NUM=35
if [ "$API" -lt $NUM ]; then
  ui_print "! Unsupported SDK $API."
  ui_print "  You have to upgrade your Android version"
  ui_print "  at least SDK $NUM to use this module."
  abort
else
  ui_print "- SDK $API"
  ui_print " "
fi

# one ui core
FILE=/data/adb/modules/OneUICore/module.prop
NUM=`grep_prop versionCode $FILE`
if [ ! -f $FILE ]; then
  ui_print "! One UI Core Magisk Module is not installed."
  ui_print "  Please read the Installation Guide!"
  abort
elif [ "$NUM" -lt 15 ]; then
  ui_print "! This version requires One UI Core Magisk Module"
  ui_print "  v1.5 or above."
  abort
else
  rm -f /data/adb/modules/OneUICore/remove
  rm -f /data/adb/modules/OneUICore/disable
fi

# recovery
mount_partitions_in_recovery

# sepolicy
FILE=$MODPATH/sepolicy.rule
DES=$MODPATH/sepolicy.pfsd
if [ "`grep_prop sepolicy.sh $OPTIONALS`" == 1 ]\
&& [ -f $FILE ]; then
  mv -f $FILE $DES
fi

# cleaning
ui_print "- Cleaning..."
PKGS=`cat $MODPATH/package.txt`
if [ "$BOOTMODE" == true ]; then
  for PKG in $PKGS; do
    FILE=`find /data/app -name *$PKG*`
    if [ "$FILE" ]; then
      RES=`pm uninstall $PKG 2>/dev/null`
    fi
  done
fi
remove_sepolicy_rule
ui_print " "

# function
conflict() {
for NAME in $NAMES; do
  DIR=/data/adb/modules_update/$NAME
  if [ -f $DIR/uninstall.sh ]; then
    sh $DIR/uninstall.sh
  fi
  rm -rf $DIR
  DIR=/data/adb/modules/$NAME
  rm -f $DIR/update
  touch $DIR/remove
  FILE=/data/adb/modules/$NAME/uninstall.sh
  if [ -f $FILE ]; then
    sh $FILE
    rm -f $FILE
  fi
  rm -rf /metadata/magisk/$NAME
  rm -rf /mnt/vendor/persist/magisk/$NAME
  rm -rf /persist/magisk/$NAME
  rm -rf /data/unencrypted/magisk/$NAME
  rm -rf /cache/magisk/$NAME
  rm -rf /cust/magisk/$NAME
done
}

# conflict
NAMES=oneuilauncher
conflict

# recents
NUM=35
if [ "`grep_prop oneui.recents $OPTIONALS`" == 1 ]; then
  if [ "$API" -ge $NUM ]; then
    RECENTS=true
  else
    RECENTS=false
    ui_print "- The recents provider is only for SDK $NUM and up"
    ui_print " "
  fi
else
  RECENTS=false
fi
if [ "$RECENTS" == true ]; then
  NAME=*RecentsOverlay.apk
  ui_print "- $MODNAME recents provider will be activated"
  ui_print "- Quick Switch module will be disabled"
  ui_print "- Renaming any other else module $NAME"
  ui_print "  to $NAME.bak"
  touch /data/adb/modules/quickstepswitcher/disable
  touch /data/adb/modules/quickswitch/disable
  sed -i 's|#r||g' $MODPATH/post-fs-data.sh
  FILES=`find /data/adb/modules* ! -path "*/$MODID/*" -type f -name $NAME`
  for FILE in $FILES; do
    mv -f $FILE $FILE.bak
  done
  ui_print " "
  DIR=/overlay/PixelConfigOverlayCommon
  [ -d /product$DIR ] && REPLACE="$REPLACE /product$DIR"
  [ -d /vendor$DIR ] && REPLACE="$REPLACE /vendor$DIR"
  [ -d /odm$DIR ] && REPLACE="$REPLACE /system/odm$DIR"
else
  rm -rf $MODPATH/system/product
fi
if [ "$RECENTS" == true ]; then
  if [ ! -d /product/overlay ]\
  || [ "`grep_prop overlay.location $OPTIONALS`" == vendor ]; then
    ui_print "- Using /vendor/overlay/ instead of /product/overlay/"
    mv -f $MODPATH/system/product $MODPATH/system/vendor
    ui_print " "
  elif [ "`grep_prop overlay.location $OPTIONALS`" == odm ]\
  && [ -d /odm/overlay ]; then
    if grep /odm /data/adb/magisk/magisk\
    || grep /odm /data/adb/magisk/magisk64\
    || grep /odm /data/adb/magisk/magisk32; then
      ui_print "- Using /odm/overlay/ instead of /product/overlay/"
      mv -f $MODPATH/system/product $MODPATH/system/odm
      ui_print " "
    else
      ui_print "! Kitsune Mask/Magisk Delta is not installed or"
      ui_print "  the version doesn't support /odm"
      ui_print " "
    fi
  fi
fi

# function
cleanup() {
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
DIR=/data/adb/modules_update/$MODID
if [ -f $DIR/uninstall.sh ]; then
  sh $DIR/uninstall.sh
fi
}

# cleanup
DIR=/data/adb/modules/$MODID
FILE=$DIR/module.prop
PREVMODNAME=`grep_prop name $FILE`
if [ "`grep_prop data.cleanup $OPTIONALS`" == 1 ]; then
  sed -i 's|^data.cleanup=1|data.cleanup=0|g' $OPTIONALS
  ui_print "- Cleaning-up $MODID data..."
  cleanup
  ui_print " "
elif [ -d $DIR ]\
&& [ "$PREVMODNAME" != "$MODNAME" ]; then
  ui_print "- Different module name is detected"
  ui_print "  Cleaning-up $MODID data..."
  cleanup
  ui_print " "
fi

# function
permissive_2() {
sed -i 's|#2||g' $MODPATH/post-fs-data.sh
}
permissive() {
FILE=/sys/fs/selinux/enforce
SELINUX=`cat $FILE`
if [ "$SELINUX" == 1 ]; then
  if ! setenforce 0; then
    echo 0 > $FILE
  fi
  SELINUX=`cat $FILE`
  if [ "$SELINUX" == 1 ]; then
    ui_print "  Your device can't be turned to Permissive state."
    ui_print "  Using Magisk Permissive mode instead."
    permissive_2
  else
    if ! setenforce 1; then
      echo 1 > $FILE
    fi
    sed -i 's|#1||g' $MODPATH/post-fs-data.sh
  fi
else
  sed -i 's|#1||g' $MODPATH/post-fs-data.sh
fi
}

# permissive
if [ "`grep_prop permissive.mode $OPTIONALS`" == 1 ]; then
  ui_print "- Using device Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive
  ui_print " "
elif [ "`grep_prop permissive.mode $OPTIONALS`" == 2 ]; then
  ui_print "- Using Magisk Permissive mode."
  rm -f $MODPATH/sepolicy.rule
  permissive_2
  ui_print " "
fi

# function
extract_lib() {
for APP in $APPS; do
  FILE=`find $MODPATH/system -type f -name $APP.apk`
  if [ -f `dirname $FILE`/extract ]; then
    ui_print "- Extracting..."
    DIR=`dirname $FILE`/lib/"$ARCHLIB"
    mkdir -p $DIR
    rm -rf $TMPDIR/*
    DES=lib/"$ABILIB"/*
    unzip -d $TMPDIR -o $FILE $DES
    cp -f $TMPDIR/$DES $DIR
    ui_print " "
  fi
done
}
hide_oat() {
for APP in $APPS; do
  REPLACE="$REPLACE
  `find $MODPATH/system -type d -name $APP | sed "s|$MODPATH||g"`/oat"
done
}

# extract
APPS="`ls $MODPATH/system/priv-app`
      `ls $MODPATH/system/app`"
ARCHLIB=arm64
ABILIB=arm64-v8a
extract_lib
ARCHLIB=arm
if echo "$ABILIST" | grep -q armeabi-v7a; then
  ABILIB=armeabi-v7a
  extract_lib
elif echo "$ABILIST" | grep -q armeabi; then
  ABILIB=armeabi
  extract_lib
else
  ABILIB=armeabi-v7a
  extract_lib
fi
ARCHLIB=x64
ABILIB=x86_64
extract_lib
ARCHLIB=x86
ABILIB=x86
extract_lib
rm -f `find $MODPATH/system -type f -name extract`
# hide
hide_oat












