import glib
import dbus
from dbus.mainloop.glib import DBusGMainLoop

def notifications(bus, message):
	try:
		l = [str(arg) for arg in message.get_args_list()]
		appName, id, appIcon, summary, body, actions, hints, expireTimeout = l
		print "%s | %s: %s - %s" % (appName, id, summary, body)
	except Exception, e:
		pass

DBusGMainLoop(set_as_default=True)

bus = dbus.SessionBus()
bus.add_match_string_non_blocking("eavesdrop=true, interface='org.freedesktop.Notifications', member='Notify'")
bus.add_message_filter(notifications)

mainloop = glib.MainLoop()
mainloop.run()

