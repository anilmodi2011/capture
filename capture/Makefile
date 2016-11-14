COMPONENT=CaptureApp
BUILD_EXTRA_DEPS += TestSerial.class
CLEAN_EXTRA = *.class TestSerialMsg.java

CFLAGS += -I$(TOSDIR)/lib/T2Hack

TestSerial.class: $(wildcard *.java) TestSerialMsg.java
	javac -target 1.6 -source 1.6 *.java

TestSerialMsg.java:
	mig java -target=null -java-classname=TestSerialMsg Define.h SuccessMessage -o $@


include $(MAKERULES)
