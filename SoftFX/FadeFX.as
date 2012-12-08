package SoftFX
{	
    import flash.utils.Timer;
    import flash.events.TimerEvent;
    import flash.events.EventDispatcher;
    import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.utils.Dictionary;
	
	public class FadeFX extends EventDispatcher
	{
		// The objects that the FadeFX class is fading.
		private var targets:Array = new Array();
		
		// Add a target. Cannot be undone.
		public function addTarget(obj:DisplayObject)
		{
			// Make sure the target has not been added yet
			for (var i:int = 0; i < targets.length; i++) if (targets[i] === obj) throw new Error("Cannot target the same object twice");
			
			// If the timer is already running, throw an error
			if (fadeTimer != null) throw new Error("Cannot assign new targets while fade is running.");
			
			// Add the target
			targets.push(obj);
		}
		
		// The timer that handles the fade
		private var fadeTimer:Timer;
		
		// User supplied information that decides how the fade is done
		private var fadeStep:Number;
		private var fadeInterval:int;
		public var fadeStop:Number = -1;
		
		// List of objects currently being faded by all FadeFX classes
		static var targetPool:Dictionary = new Dictionary();
		
		// The fadeTimer's Timer event
		function fadeTimer_Timer(event:TimerEvent):void
		{
			// When the fade is complete, finished is set to 1, else it will equal 0 or -1
			var finished:int = -1;
			
			// Loop through all of the targets
			for (var i:int = 0; i < targets.length; i++) 
			{
				// Check to see if another fade object has been applied to one of our targets.
				if (targetPool[targets[i]] > 1)
				{
					// Stop this fade to allow the other fade to complete
					finished = 1;
					break;
				}
				
				// Apply the fadeStep to the target's alpha value
				targets[i].alpha += fadeStep;
				
				// Check to see if the fade is finished
				if ((targets[i].alpha <= 0 && fadeStep < 0) || (targets[i].alpha >= 1 && fadeStep > 0) ||
					(fadeStop != -1 && ((targets[i].alpha <= fadeStop && fadeStep < 0) || (targets[i].alpha >= fadeStop && fadeStep > 0))))
				{
					if (finished != 0) finished = 1;
				}
				else
				{
					finished = 0;
				}
			}
			
			// Check to see if the fade is finished
			if (finished == 1)
			{
				// Update the targetPool
				for (var j:int = 0; j < targets.length; j++) targetPool[targets[j]]--;
				
				// Alert the user that the fade has finished
				dispatchEvent(new Event("Finished"));
				
				// Stop and delete the fadeTimer.
				fadeTimer.stop();
				fadeTimer = null;
			}
		}
		
		// Start a fade with the specified step and interval
		public function start(step:Number, interval:int)
		{
			// CHeck to make sure a fade can be started right now
			if (fadeTimer != null || startTimer != null) return; //throw new Error("Fade transition already in progress");
			if (targets.length == 0) throw new Error("No targets have been selected");
			if (step == 0) throw new Error("Step must be non zero");
			
			// Save the fade's step and interval
			fadeStep = step;
			fadeInterval = interval;
			
			// Add the targets to the target pool
			for (var i:int = 0; i < targets.length; i++) 
			{
				targetPool[targets[i]]++;
				if (!(targetPool[targets[i]] > 0)) targetPool[targets[i]] = 1;
			}
			
			// Trigger the startTimer's timer event manually
			startTimer_Timer(new TimerEvent(TimerEvent.TIMER));
		}
		
		// The timer that is used to ensure the fade is only started when there are no other fades affecting the targets
		var startTimer:Timer = null;
		
		// startTimer's Timer event
		private function startTimer_Timer(event:TimerEvent):void
		{
			// Ensure that none of the fade's targets are currenlty being faded by another class
			for (var i:int = 0; i < targets.length; i++)
			{
				if (targetPool[targets[i]] > 1)
				{
					// If the startTimer hasn't been created yet
					if (startTimer == null) 
					{
						// Create the start timer and set its Timer event
						startTimer = new Timer(1);
						startTimer.addEventListener(TimerEvent.TIMER, startTimer_Timer);
					}
					
					// Start the startTimer
					startTimer.start();
					
					// Can't start the fade yet
					return;
				}
			}
			
			// Remove the start timer if needed
			if (startTimer != null)
			{
				startTimer.stop();
				startTimer = null;
			}
			
			// Start the fade
			fadeTimer = new Timer(fadeInterval);
			fadeTimer.addEventListener(TimerEvent.TIMER, fadeTimer_Timer);
			fadeTimer.start();
		}
	}
}