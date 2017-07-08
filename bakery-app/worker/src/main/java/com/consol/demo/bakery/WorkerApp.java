/*
 * Copyright 2006-2015 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.consol.demo.bakery;

import org.apache.camel.spring.Main;

/**
 * @author Christoph Deppisch
 * @since 2.4
 */
public class WorkerApp extends Main {

    public static final String TYPE = "FACTORY_TYPE";
    public static final String COSTS = "FACTORY_COSTS";

    public static void main(String[] args) throws Exception {
        if (args.length > 0 && args[0] != null) {
            System.setProperty(TYPE, args[0]);
        }

        if (args.length > 1 && args[1] != null) {
            System.setProperty(COSTS, args[1]);
        }
        System.out.println(String.format("START WITH: FACTORY_TYPE '%s' and FACTORY_COSTS '%s'",
                System.getProperty(TYPE), System.getProperty(COSTS)));
        WorkerApp application = new WorkerApp();
        application.run();
    }
}
