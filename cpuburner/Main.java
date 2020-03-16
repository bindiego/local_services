import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.atomic.LongAdder;

public class Main
{
    public static void main(String... args) throws InterruptedException
    {
        if (args.length != 1)
        {
            System.err.println("Please provide a single argument: the number of threads to run.");
            System.exit(1);
        }

        int numThreads = Integer.parseInt(args[0]);

        if (numThreads < 1)
        {
            System.err.println("Number of threads should be at least 1");
            System.exit(1);
        }

        LongAdder counter = new LongAdder();

        List<CalculationThread> runningCalcs = new ArrayList<>();
        List<Thread> runningThreads = new ArrayList<>();

        System.out.printf("Starting %d threads\n", numThreads);

        for (int i = 0; i < numThreads; i++)
        {
            CalculationThread r = new CalculationThread(counter);
            Thread t = new Thread(r);
            runningCalcs.add(r);
            runningThreads.add(t);
            t.start();
        }

        for (int i = 0; i < 15; i++)
        {
            counter.reset();
            try
            {
                Thread.sleep(1000);
            }
            catch (InterruptedException e)
            {
                break;
            }
            System.out.printf("[%d] Calculations per second: %d (%.2f per thread)\n",
                              i,
                              counter.longValue(),
                              (double)(counter.longValue()) / numThreads
            );
        }

        for (int i = 0; i < runningCalcs.size(); i++)
        {
            runningCalcs.get(i).stop();
            runningThreads.get(i).join();
        }

    }

    public static class CalculationThread implements Runnable
    {
        private final Random rng;
        private final LongAdder calculationsPerformed;
        private boolean stopped;
        private double store;

        public CalculationThread(LongAdder calculationsPerformed)
        {
            this.calculationsPerformed = calculationsPerformed;
            this.stopped = false;
            this.rng = new Random();
            this.store = 1;
        }

        public void stop()
        {
            this.stopped = true;
        }

        @Override
        public void run()
        {
            while (! this.stopped)
            {
                double r = this.rng.nextFloat();
                double v = Math.sin(Math.cos(Math.sin(Math.cos(r))));
                this.store *= v;
                this.calculationsPerformed.add(1);
            }
        }
    }
}
