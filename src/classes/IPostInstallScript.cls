/**
 * Created by cshah on 5/29/2017.
 */

public interface IPostInstallScript {

    /**
     * Mandetory
     */

    /**
     * this must be implemented by Post install script that provides sequence number
     */
    Integer getSequenceNumber();

    /**
     * Post script impl needs to provide description
     */
    String getDescription();

    /**
     * Post Install script Impl needs to provide execution log that will goto email and database
     */
    String getExecutionLog();

    /**
     * execut script. If start method is not implemented, this will be called only once.
     */
    void executeScript(Database.BatchableContext bc, List<SObject> sObjects);


    /**
     * Optional
     */

    /**
     * If start method is implemented, please override this method to return the batch size.
     */
    Integer getBatchSize();

    /**
     * start script : return the query locator and executeScript method will be called for those data
     */
    Database.QueryLocator startScript(Database.BatchableContext bc);

    /**
     * this script is optional, will be called at the end if everything is successful.
     */
    void finishScript(Database.BatchableContext bc);
}