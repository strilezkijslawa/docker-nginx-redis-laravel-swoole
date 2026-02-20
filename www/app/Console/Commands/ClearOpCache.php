<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;

class ClearOpCache extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'opcache:clear';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Reset opcache';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        if (function_exists('opcache_reset')) {
            opcache_reset();
            $this->info('Successful reset opcache');
        }
    }
}
