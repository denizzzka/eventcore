module eventcore.core;

public import eventcore.driver;

import eventcore.drivers.posix.select;
import eventcore.drivers.posix.epoll;
import eventcore.drivers.posix.kqueue;
import eventcore.drivers.libasync;
import eventcore.drivers.winapi.winapidriver;

version (EventcoreEpollDriver) alias NativeEventDriver = EpollEventDriver;
else version (EventcoreKqueueDriver) alias NativeEventDriver = KqueueEventDriver;
else version (EventcoreWinAPIDriver) alias NativeEventDriver = WinAPIEventDriver;
else version (EventcoreLibasyncDriver) alias NativeEventDriver = LibasyncEventDriver;
else version (EventcoreSelectDriver) alias NativeEventDriver = SelectEventDriver;
else alias NativeEventDriver = EventDriver;

@property NativeEventDriver eventDriver()
@safe @nogc nothrow {
	static if (is(NativeEventDriver == EventDriver))
		assert(s_driver !is null, "setupEventDriver() was not called for this thread.");
	else
		assert(s_driver !is null, "eventcore.core static constructor didn't run!?");
	return s_driver;
}

static if (!is(NativeEventDriver == EventDriver)) {
	static this()
	{
		if (!s_driver) s_driver = new NativeEventDriver;
	}

	shared static this()
	{
		s_driver = new NativeEventDriver;
	}
} else {
	void setupEventDriver(EventDriver driver)
	{
		assert(driver !is null, "The event driver instance must be non-null.");
		assert(!s_driver, "Can only set up the event driver once per thread.");
		s_driver = driver;
	}
}

private NativeEventDriver s_driver;
