/**
 * Created by cshah on 6/23/2017.
 */

public with sharing class ServiceFactory {

    private static ServiceFactory instance;

    /**
     * private constructor
     */
    private ServiceFactory() {

    }

    /**
     * singleton get instance
     */
    public static ServiceFactory getInstance() {
        if( instance == null ) {
            instance = new ServiceFactory();
        }
        return instance;
    }

    public IPostInstallService getPostInstallService() {
        return PostInstallService.getInstance();
    }

}